#[cfg(test)]
mod tests {
    // use cairo_wallet::multi_sig::{Imulti_sig, multi_sig, Imulti_sigDispatcher, Imulti_sigDispatcherTrait};
    use cairo_wallet::mocks::multi_sigDummy::{Imulti_sigDummy, multi_sigDummy, Imulti_sigDummyDispatcher, Imulti_sigDummyDispatcherTrait};
    use starknet::ClassHash;
    use starknet::contract_address::contract_address_const;
    use core::starknet::contract_address::ContractAddress;
    use core::array::ArrayTrait;
    use snforge_std::{declare, ContractClassTrait, start_cheat_caller_address};
    use core::traits::{Into, TryInto};
    use core::byte_array::ByteArray;
    // use starknet::deploy_syscall;
    // use starknet::SyscallResultTrait;

    // Helper function to deploy the contract
    fn setup()-> (ContractAddress,ContractAddress) {
        let contract_class= declare("multi_sigDummy").unwrap();

        let admin: ContractAddress = contract_address_const::<1>();

        let mut calldata = ArrayTrait::new();
        admin.serialize(ref calldata);
        let (contract_address, _) = contract_class.deploy(@calldata).unwrap();
        (contract_address,admin)
    }
    // fn deploy_contract() -> (multi_sig::ContractState,ContractAddress) {

    //     let admin: ContractAddress = contract_address_const::<1>();

    //     let mut calldata = ArrayTrait::new();
    //     admin.serialize(ref calldata);
    //     let contract = multi_sig::constructor(calldata);
    //     (contract,admin)
    // }
//    fn setup_counter() -> (Imulti_sigDispatcher,ContractAddress) {

//     let admin: ContractAddress = contract_address_const::<1>();
//     let (address, _) = deploy_syscall(
//         multi_sig::TEST_CLASS_HASH.try_into().unwrap(), 0, array![admin.into()].span(), false
//     )
//         .unwrap_syscall();
//     (Imulti_sigDispatcher { contract_address: address },admin)
// }
    
    fn create_address(value: felt252) -> ContractAddress {
    if value == 2 {
        contract_address_const::<2>()
    } else if value == 3 {
        contract_address_const::<3>()
    } else {
        contract_address_const::<1>()
    }
    }

    fn addOwner(owner: ContractAddress)->(Imulti_sigDummyDispatcher,ContractAddress,ContractAddress){
        let (contract_address,admin) = setup();
        let dispatcher = Imulti_sigDummyDispatcher { contract_address };

        start_cheat_caller_address(contract_address, admin);
        dispatcher._add_owner(owner);
        (dispatcher,contract_address,admin)
    }

     #[test]
    fn test_create_tx() {
        let owner = create_address(2);
        let (dispatcher,contract_address,_admin) = addOwner(owner);
        start_cheat_caller_address(contract_address, owner);

        let to = contract_address_const::<434>();
        let value: u256 = 1000;
        let data: felt252 = 1;

        dispatcher.create_tx(to, value, data);

        let tx_details = dispatcher.get_tx_details(0);
        assert(tx_details.to == to, 'Invalid recipient');
        assert(tx_details.value == value, 'Invalid value');
        assert(tx_details.data == data, 'Invalid data');
        assert(tx_details.is_executed == false, 'Should not be executed');
    }

    #[test]
    fn test_approve_and_execute_tx() {
        let owner = create_address(2);
        let (dispatcher,contract_address,_admin) = addOwner(owner);

        start_cheat_caller_address(contract_address, owner);


        dispatcher.create_tx(contract_address_const::<434>(), 1000, 1);
        
        dispatcher.approve_tx(0);
        
        let tx_details = dispatcher.get_tx_details(0);
        assert(tx_details.number_of_conformation == 1, 'Should have 1 confirmation');

        dispatcher.execute_tx(0);
        
        assert(dispatcher.tx_executed(0) == true, 'Transaction should be executed');
    }

    #[test]
    fn test_re_approve_tx() {
       let owner = create_address(2);
        let (dispatcher,contract_address,_admin) = addOwner(owner);

        start_cheat_caller_address(contract_address, owner);


        dispatcher.create_tx(contract_address_const::<434>(), 1000, 1);
        
        dispatcher.approve_tx(0);
        
        let tx_details = dispatcher.get_tx_details(0);
        assert(tx_details.number_of_conformation == 1, 'Should have 1 confirmation');
        dispatcher.re_approve_tx(0);

        let tx_details = dispatcher.get_tx_details(0);
        assert(tx_details.number_of_conformation == 0, 'Should have 0 confirmations');
    }

    #[test]
    fn test_tx_exist() {

        let owner = create_address(2);

        let (dispatcher,contract_address,_admin) = addOwner(owner);
        start_cheat_caller_address(contract_address, owner);

        let to = create_address(456);
        dispatcher.create_tx(to, 1000, 1);

        assert(dispatcher.tx_exist(0) == true, 'Transaction should exist');
        assert(dispatcher.tx_exist(1) == false, 'Transaction should not exist');
    }

    #[test]
    #[should_panic(expected: ('Caller is not the owner',))]
    fn test_create_tx_non_owner() {

         let owner = create_address(2);

        let (dispatcher,contract_address,_admin) = addOwner(owner);

        // Set caller as non-owner
        start_cheat_caller_address(contract_address, contract_address_const::<456>());

        let to = create_address(789);
        dispatcher.create_tx(to, 1000, 1);
    }

    #[test]
    #[fuzzer(runs: 100, seed: 38)]
    fn fuzz_create_and_approve_tx(value: u256, data: felt252) {
        
        let owner = create_address(2);

        let (dispatcher,contract_address,_admin)= addOwner(owner);

        // Set caller as admin
        start_cheat_caller_address(contract_address,owner);

        let to = create_address(456);
        dispatcher.create_tx(to, value, data);

        let tx_details = dispatcher.get_tx_details(0);
        assert(tx_details.value == value, 'Invalid value');
        assert(tx_details.data == data, 'Invalid data');

        dispatcher.approve_tx(0);
        let approved_tx = dispatcher.get_tx_details(0);
        assert(approved_tx.number_of_conformation == 1, 'Should have 1 confirmation');
    }
}


