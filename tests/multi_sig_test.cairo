
// //     use starknet::ContractAddress;
// //     use super::multi_sig;
// //     use super::Imulti_sig;
// //     use super::Transaction;
// //     use super::access_registry::Access_registrable_component;
// //     use super::access_registry::IAccess_registrable;
// //     use starknet::ContractAddress;
// //     use starknet::testing::{set_caller_address, set_contract_address};
// //     use core::num::traits::Zero;
// //     use starknet::class_hash::Felt252TryIntoClassHash;
// //     use starknet::ClassHash;
// //     use starknet::testing;
// //     use snforge_std::{declare, ContractClassTrait};

// //     // // Helper function to create a dummy ContractAddress
// //     // fn create_address(value: felt252) -> ContractAddress {
// //     //     starknet::contract_address_const::<'value'>()
// //     // }

// //     // Helper function to deploy the contract
// //    // Helper function to deploy the contract
// // fn deploy_contract(name: felt252) -> ContractAddress{
// //     // First, declare the contract class
// //     let contract = declare(name);
// //     contract.deploy(@ArrayTrait::new()).unwrap()
    
// // }
// //     // Your test cases go here
// //     #[test]
// //     fn test_constructor() {
// //         let contract = deploy_contract();
// //         let admin = create_address('admin');
// //         assert_eq!(contract.admin_of_wallet(), admin, "Admin should be set correctly");
// //     }

// //     #[test]
// //     fn test_constructor() {
// //         let contract = deploy_contract();
// //         let admin = create_address('admin');
// //         assert_eq!(contract.admin_of_wallet(), admin, "Admin should be set correctly");
// //     }

// //     #[test]
// //     fn test_create_tx() {
// //         let mut contract = deploy_contract();
// //         let owner = create_address('owner');
// //         let to = create_address('recipient');
// //         let value = 100;
// //         let data = 'test_data';

// //         // Add owner
// //         set_caller_address(create_address('admin'));
// //         contract.add_owner(owner);

// //         // Create transaction
// //         set_caller_address(owner);
// //         contract.create_tx(to, value, data);

// //         // Check transaction details
// //         let tx = contract.get_tx_details(0);
// //         assert_eq!(tx.from, owner, "From address should match");
// //         assert_eq!(tx.to, to, "To address should match");
// //         assert_eq!(tx.value, value, "Value should match");
// //         assert_eq!(tx.data, data, "Data should match");
// //         assert_eq!(tx.number_of_conformation, 0, "Initial confirmations should be 0");
// //         assert_eq!(tx.is_executed, false, "Transaction should not be executed");
// //     }

// //     #[test]
// //     fn test_approve_tx() {
// //         let mut contract = deploy_contract();
// //         let owner1 = create_address('owner1');
// //         let owner2 = create_address('owner2');
// //         let to = create_address('recipient');

// //         // Add owners
// //         set_caller_address(create_address('admin'));
// //         contract.add_owner(owner1);
// //         contract.add_owner(owner2);

// //         // Create transaction
// //         set_caller_address(owner1);
// //         contract.create_tx(to, 100, 'test_data');

// //         // Approve transaction
// //         contract.approve_tx(0);
// //         set_caller_address(owner2);
// //         contract.approve_tx(0);

// //         // Check transaction details
// //         let tx = contract.get_tx_details(0);
// //         assert_eq!(tx.number_of_conformation, 2, "Should have 2 confirmations");
// //     }

// //     #[test]
// //     fn test_re_approve_tx() {
// //         let mut contract = deploy_contract();
// //         let owner = create_address('owner');
// //         let to = create_address('recipient');

// //         // Add owner
// //         set_caller_address(create_address('admin'));
// //         contract.add_owner(owner);

// //         // Create and approve transaction
// //         set_caller_address(owner);
// //         contract.create_tx(to, 100, 'test_data');
// //         contract.approve_tx(0);

// //         // Re-approve (revoke) transaction
// //         contract.re_approve_tx(0);

// //         // Check transaction details
// //         let tx = contract.get_tx_details(0);
// //         assert_eq!(tx.number_of_conformation, 0, "Should have 0 confirmations after re-approve");
// //     }

// //     #[test]
// //     fn test_execute_tx() {
// //         let mut contract = deploy_contract();
// //         let owner1 = create_address('owner1');
// //         let owner2 = create_address('owner2');
// //         let to = create_address('recipient');

// //         // Add owners
// //         set_caller_address(create_address('admin'));
// //         contract.add_owner(owner1);
// //         contract.add_owner(owner2);

// //         // Create and approve transaction
// //         set_caller_address(owner1);
// //         contract.create_tx(to, 100, 'test_data');
// //         contract.approve_tx(0);
// //         set_caller_address(owner2);
// //         contract.approve_tx(0);

// //         // Execute transaction
// //         contract.execute_tx(0);

// //         // Check transaction status
// //         assert!(contract.tx_executed(0), "Transaction should be executed");
// //     }

// //     #[test]
// //     #[should_panic(expected: ('Caller is not the owner',))]
// //     fn test_create_tx_not_owner() {
// //         let mut contract = deploy_contract();
// //         set_caller_address(create_address('not_owner'));
// //         contract.create_tx(create_address('to'), 100, 'test_data');
// //     }

// //     #[test]
// //     #[should_panic(expected: ('tx already approved',))]
// //     fn test_approve_tx_twice() {
// //         let mut contract = deploy_contract();
// //         let owner = create_address('owner');
// //         let to = create_address('recipient');

// //         set_caller_address(create_address('admin'));
// //         contract.add_owner(owner);

// //         set_caller_address(owner);
// //         contract.create_tx(to, 100, 'test_data');
// //         contract.approve_tx(0);
// //         contract.approve_tx(0);  // This should panic
// //     }

// //     #[test]
// //     #[should_panic(expected: ('not enough approval for tx',))]
// //     fn test_execute_tx_without_enough_approvals() {
// //         let mut contract = deploy_contract();
// //         let owner = create_address('owner');
// //         let to = create_address('recipient');

// //         set_caller_address(create_address('admin'));
// //         contract.add_owner(owner);

// //         set_caller_address(owner);
// //         contract.create_tx(to, 100, 'test_data');
// //         contract.approve_tx(0);
// //         contract.execute_tx(0);  // This should panic
// //     }

// //     #[test]
// //     #[should_panic(expected: ('tx not exit or already executed',))]
// //     fn test_approve_non_existent_tx() {
// //         let mut contract = deploy_contract();
// //         let owner = create_address('owner');

// //         set_caller_address(create_address('admin'));
// //         contract.add_owner(owner);

// //         set_caller_address(owner);
// //         contract.approve_tx(999);  // This should panic
// //     }




// #[cfg(test)]
// mod test {
//     use core::serde::Serde;
//     use super::{IERC20, ERC20Token, IERC20Dispatcher, IERC20DispatcherTrait};
//     use starknet::ContractAddress;
//     use starknet::contract_address::contract_address_const;
//     use core::array::ArrayTrait;
//     use snforge_std::{declare, ContractClassTrait, fs::{FileTrait, read_txt}};
//     use snforge_std::{start_prank, stop_prank, CheatTarget};
//     use snforge_std::PrintTrait;
//     use core::traits::{Into, TryInto};
// }

// // Helper function to deploy the contract
// fn deploy_contract(name: felt252) -> ContractAddress {
//     let contract = declare(name);
//     contract.deploy(@ArrayTrait::new()).unwrap()
// }

// // Helper function to create a dummy address
// fn create_address() -> ContractAddress {
//     starknet::contract_address_const::<0x123>()
// }

// #[test]
// fn test_create_tx() {
//     let contract_address = deploy_contract('multi_sig');
//     let dispatcher = Imulti_sigDispatcher { contract_address };

//     let to = create_address();
//     let value: u256 = 1000;
//     let data: felt252 = 123;

//     dispatcher.create_tx(to, value, data);

//     // Verify the transaction was created
//     let tx_details = dispatcher.get_tx_details(0);
//     assert(tx_details.to == to, 'Invalid to address');
//     assert(tx_details.value == value, 'Invalid value');
//     assert(tx_details.data == data, 'Invalid data');
//     assert(tx_details.is_executed == false, 'Should not be executed');
// }

// #[test]
// fn test_approve_tx() {
//     let contract_address = deploy_contract('multi_sig');
//     let dispatcher = Imulti_sigDispatcher { contract_address };

//     // Create a transaction first
//     let to = create_address();
//     dispatcher.create_tx(to, 1000, 123);

//     // Approve the transaction
//     dispatcher.approve_tx(0);

//     // Verify the transaction was approved
//     let tx_details = dispatcher.get_tx_details(0);
//     assert(tx_details.number_of_conformation == 1, 'Should have 1 confirmation');
// }

// #[test]
// fn test_execute_tx() {
//     let contract_address = deploy_contract('multi_sig');
//     let dispatcher = Imulti_sigDispatcher { contract_address };

//     // Create a transaction
//     let to = create_address();
//     dispatcher.create_tx(to, 1000, 123);

//     // Approve the transaction (assuming we need only one approval)
//     dispatcher.approve_tx(0);

//     // Execute the transaction
//     dispatcher.execute_tx(0);

//     // Verify the transaction was executed
//     assert(dispatcher.tx_executed(0) == true, 'Transaction should be executed');
// }

// #[test]
// fn test_re_approve_tx() {
//     let contract_address = deploy_contract('multi_sig');
//     let dispatcher = Imulti_sigDispatcher { contract_address };

//     // Create and approve a transaction
//     let to = create_address();
//     dispatcher.create_tx(to, 1000, 123);
//     dispatcher.approve_tx(0);

//     // Re-approve (revoke) the transaction
//     dispatcher.re_approve_tx(0);

//     // Verify the transaction approval was revoked
//     let tx_details = dispatcher.get_tx_details(0);
//     assert(tx_details.number_of_conformation == 0, 'Should have 0 confirmations');
// }

// #[test]
// fn test_tx_exist() {
//     let contract_address = deploy_contract('multi_sig');
//     let dispatcher = Imulti_sigDispatcher { contract_address };

//     // Create a transaction
//     let to = create_address();
//     dispatcher.create_tx(to, 1000, 123);

//     // Verify the transaction exists
//     assert(dispatcher.tx_exist(0) == true, 'Transaction should exist');
//     assert(dispatcher.tx_exist(1) == false, 'Transaction should not exist');
// }

// #[test]
// fn test_upgrade() {
//     let contract_address = deploy_contract('multi_sig');
//     let safe_dispatcher = Imulti_sigSafeDispatcher { contract_address };

//     // Create a dummy class hash for upgrade
//     let new_class_hash: ClassHash = ClassHash { inner: 0x456 };

//     // Attempt to upgrade the contract
//     match safe_dispatcher.upgrade(new_class_hash) {
//         Result::Ok(_) => {},
//         Result::Err(panic_data) => {
//             panic_with_felt252('Upgrade should succeed');
//         }
//     };
// }