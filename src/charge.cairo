use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[derive(Model, Copy, Drop, Serde)]
struct Store {
    #[key]
    id: u32,
    value1: felt252,
    value2: felt252,
    value3: felt252,
    value4: felt252,
}


#[starknet::interface]
trait IContract<TContractState> {
    fn emit_contract_event(self: @TContractState, count: u32);
}

#[dojo::contract]
mod charge {
    use starknet::ContractAddress;
    use starknet::get_caller_address;

    use super::{IContract, Store};

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Event0: Event0,
    }

    #[derive(Drop, starknet::Event)]
    struct Event0 {
        value1: felt252,
        value2: felt252,
        value3: felt252,
        value4: felt252,
    }


    #[external(v0)]
    impl ContractImpl of IContract<ContractState> {
        fn emit_contract_event(self: @ContractState, count: u32) {
            let world = self.world_dispatcher.read();

            let mut i = 0;
            loop {
                if i == count {
                    break;
                }

                set!(
                    world, Store { id: world.uuid(), value1: 42, value2: 42, value3: 42, value4: 42 }
                );

                emit!(world,Event0 { value1: 42, value2: 42, value3: 42, value4: 42 });
                i += 1;
            };
        }
    }
}

