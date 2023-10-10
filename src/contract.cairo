use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};


#[derive(Model, Copy, Drop, Serde)]
struct Log {
    #[key]
    id: u32,
    #[key]
    address: ContractAddress,
    i0: u32,
    i1: u32,
    i2: u32,
    i3: u32,
}

#[derive(Model, Copy, Drop, Serde)]
struct LogWithEnum {
    #[key]
    id: u32,
    #[key]
    address: ContractAddress,
    i0: u32,
    i1: u32,
    i2: u32,
    e: TestEnum,
}


#[starknet::interface]
trait IContract<TContractState> {
    fn emit_events(self: @TContractState, count: u32);
    fn emit_events_with_enum(self: @TContractState, count: u32);
}

#[starknet::contract]
mod contract {
    use starknet::ContractAddress;
    use starknet::get_caller_address;

    use super::{IWorldDispatcher, IWorldDispatcherTrait};
    use super::{IContract,Log,LogWithEnum, TestEnum};

    #[storage]
    struct Storage {
        world_dispatcher: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, world: ContractAddress,) {
        self.world_dispatcher.write(world);
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Event0: Event0,
    }

    #[derive(Drop, starknet::Event)]
    struct Event0 {
        caller: ContractAddress,
        id: u32
    }


    #[external(v0)]
    impl ContractImpl of IContract<ContractState> {
        fn emit_events(self: @ContractState, count: u32) {
            let world = IWorldDispatcher { contract_address: self.world_dispatcher.read() };

            let mut i = 0;
            loop {
                if i == count {
                    break;
                }

                set!(
                    world,
                    Log {
                        id: world.uuid(), address: get_caller_address(), i0: i, i1: i, i2: i, i3: i
                    }
                );

                i += 1;
            };
        }

        fn emit_events_with_enum(self: @ContractState, count: u32) {
            let world = IWorldDispatcher { contract_address: self.world_dispatcher.read() };

            let mut i = 0;
            loop {
                if i == count {
                    break;
                }

                set!(
                    world,
                    LogWithEnum {
                        id: world.uuid(),
                        address: get_caller_address(),
                        i0: i,
                        i1: i,
                        i2: i,
                        e: TestEnum::Value0
                    }
                );

                i += 1;
            };
        }
    }
}


use dojo::database::schema::{
    Enum, Member, Ty, Struct, SchemaIntrospection, serialize_member, serialize_member_type
};

#[derive(Copy, Drop, Serde, PartialEq)]
enum TestEnum {
    Value0,
    Value1,
    Value2,
}

impl TestEnumIntrospectionImpl of SchemaIntrospection<TestEnum> {
    #[inline(always)]
    fn size() -> usize {
        1
    }

    #[inline(always)]
    fn layout(ref layout: Array<u8>) {
        layout.append(8);
    }

    #[inline(always)]
    fn ty() -> Ty {
        Ty::Enum(
            Enum {
                name: 'TestEnum',
                attrs: array![].span(),
                children: array![
                    ('Value0', serialize_member_type(@Ty::Tuple(array![].span()))),
                    ('Value1', serialize_member_type(@Ty::Tuple(array![].span()))),
                    ('Value2', serialize_member_type(@Ty::Tuple(array![].span()))),
                ]
                    .span()
            }
        )
    }
}
