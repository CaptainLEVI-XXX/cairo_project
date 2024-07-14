#[cfg(test)]
    use starknet::ContractAddress;
    use starknet::ClassHash;
    use starknet::contract_address::contract_address_const;
    use core::array::ArrayTrait;
    use snforge_std::{declare, ContractClassTrait, start_cheat_caller_address};
    use core::traits::{Into, TryInto};
    use core::byte_array::ByteArray;
    use starknet::testing::set_caller_address;
    use core::num::traits::Zero;
    use cairo_wallet::mocks::DummyContract::{IDummyContractDispatcher, IDummyContractDispatcherTrait};
    // use cairo_wallet::mocks::mock2::{IMockContractDispatcher, IMockContractDispatcherTrait};
    // use cairo_wallet::access_registry::{IAccess_registrableDispatcher};

    // Helper function to create a dummy ContractAddress
    fn create_address(value: felt252) -> ContractAddress {
    if value == 2 {
        contract_address_const::<2>()
    } else if value == 3 {
        contract_address_const::<3>()
    } else {
        contract_address_const::<1>()
    }
    }

    fn setup()-> (ContractAddress,ContractAddress) {
        let contract_class= declare("DummyContract").unwrap();

        let admin: ContractAddress = contract_address_const::<1>();

        let mut calldata = ArrayTrait::new();
        admin.serialize(ref calldata);
        let (contract_address, _) = contract_class.deploy(@calldata).unwrap();
        (contract_address,admin)
    }


    #[test]
    fn test_init() {
        let (contract_address,_) = setup();
        let dispatcher = IDummyContractDispatcher{ contract_address };

        // Set caller as admin
        let owner =create_address(1);
        start_cheat_caller_address(contract_address,owner);

        assert_eq!(dispatcher.admin_of_wallet(),owner, "Admin should be set correctly");
    }

    #[test]
    fn test_add_owner() {
        let (contract_address,_) = setup();
        let dispatcher = IDummyContractDispatcher{ contract_address };

        // Set caller as admin
        let admin =create_address(1);
        let new_owner = create_address(2);
        
        start_cheat_caller_address(contract_address,admin);
        dispatcher.add_owner(new_owner);

        assert_eq!(dispatcher.is_owner(new_owner),true, "New owner should be added");
        assert_eq!(dispatcher.total_owners_of_Wallet(), 1, "Total owners should be 1");
        assert_eq!(dispatcher.required_owners(), 1, "Required owners should be 1");
    }

    #[test]
    #[should_panic(expected :('NOT_ADMIN',))]
    fn test_add_owner_not_admin() {
        let (contract_address,_) = setup();
        let dispatcher = IDummyContractDispatcher{ contract_address };

        let new_owner = create_address(3);
        
        start_cheat_caller_address(contract_address,new_owner);
        dispatcher.add_owner(new_owner);
    }

    #[test]
    fn test_remove_owner() {
         let (contract_address,admin) = setup();
        let dispatcher = IDummyContractDispatcher{ contract_address };
        
        let new_owner = create_address(2);
        start_cheat_caller_address(contract_address,admin);
        
        dispatcher.add_owner(new_owner);

        dispatcher.remove_owner(new_owner);

        assert_eq!(dispatcher.is_owner(new_owner),false, "Owner should be removeda");
        assert_eq!(dispatcher.total_owners_of_Wallet(), 0, "Total owners should be 0");
        assert_eq!(dispatcher.required_owners(), 0, "Required owners should be 0");
    }

    #[test]
    #[should_panic(expected:('NOT_ADMIN',))]
    fn test_remove_owner_not_owner() {
        let (contract_address,admin) = setup();
        let dispatcher = IDummyContractDispatcher{ contract_address };

        let new_owner = create_address(2);
        start_cheat_caller_address(contract_address,admin);
        
        dispatcher.add_owner(new_owner);
        //UnKnown  Trying to remove the owner
        start_cheat_caller_address(contract_address,contract_address_const::<123>());

        dispatcher.remove_owner(new_owner);
    }

    #[test]
    fn test_transfer_signature() {

        let (contract_address,admin) = setup();
        let dispatcher = IDummyContractDispatcher{ contract_address };

        let old_owner = create_address(2);
        start_cheat_caller_address(contract_address,admin);
        
        dispatcher.add_owner(old_owner);

        start_cheat_caller_address(contract_address,old_owner);

        let new_owner = contract_address_const::<5555>();
        dispatcher.transfer_signature(new_owner);

        assert_eq!(dispatcher.is_owner(old_owner),false, "Old owner should be removed");
        assert_eq!(dispatcher.is_owner(new_owner),true, "New owner should be added");
        assert_eq!(dispatcher.total_owners_of_Wallet(), 1, "Total owners should remain 1");
    }

    #[test]
    #[should_panic(expected:('Caller is not the owner',))]
    fn test_transfer_signature_not_owner() {
        let (contract_address,admin) = setup();
        let dispatcher = IDummyContractDispatcher{ contract_address };

        let old_owner = create_address(2);
        start_cheat_caller_address(contract_address,admin);
        
        dispatcher.add_owner(old_owner);
        let hacker = contract_address_const::<5555>();
        start_cheat_caller_address(contract_address,hacker);
        dispatcher.transfer_signature(hacker);
    }

    #[test]
    #[should_panic(expected : ('Caller is Already owner',))]
    fn test_transfer_signature_to_existing_owner() {
        let (contract_address,admin) = setup();
        let dispatcher = IDummyContractDispatcher{ contract_address };

        let old_owner_1 = create_address(2);
        let old_owner_2 = create_address(3);
        start_cheat_caller_address(contract_address,admin);
        
        dispatcher.add_owner(old_owner_1);
        dispatcher.add_owner(old_owner_2);

        start_cheat_caller_address(contract_address,old_owner_1);

        dispatcher.transfer_signature(old_owner_2);

    }

    #[test]
    fn test_required_owners() {
        
        let (contract_address,admin) = setup();
        let dispatcher = IDummyContractDispatcher{ contract_address };
        
        start_cheat_caller_address(contract_address,admin);

        dispatcher.add_owner(create_address(2));
        assert_eq!(dispatcher.required_owners(), 1, "Required owners should be 1");

        dispatcher.add_owner(create_address(3));
        assert_eq!(dispatcher.required_owners(), 2, "Required owners should be 2");

        dispatcher.add_owner(contract_address_const::<5555>());
        assert_eq!(dispatcher.required_owners(), 2, "Required owners should be 2");

        dispatcher.add_owner(contract_address_const::<434>());
        assert_eq!(dispatcher.required_owners(), 3, "Required owners should be 3");
    }