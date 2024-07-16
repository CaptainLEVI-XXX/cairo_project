// use cairo_wallet::multi_sig::{Imulti_sig, multi_sig, Imulti_sigDispatcher, Imulti_sigDispatcherTrait};
// use cairo_wallet::multi_V2::{Imulti_V2, multi_V2, Imulti_V2Dispatcher, Imulti_V2DispatcherTrait};
// use openzeppelin::upgrades::UpgradeableComponent;
// use starknet::ClassHash;
// use starknet::ContractAddress;
// use starknet::class_hash::class_hash_const;
// use starknet::contract_address_const;

// const VALUE: felt252 = 123;



// fn CLASS_HASH_ZERO() -> ClassHash {
//     class_hash_const::<0>()
// }

// fn V2_CLASS_HASH() -> ClassHash {
//     multi_V2::TEST_CLASS_HASH.try_into().unwrap()
// }

// fn ZERO() -> ContractAddress {
//     contract_address_const::<0>()
// }

// // //
// // // Setup
// // //

// // fn setup()-> ContractAddress {
// //         let contract_class= declare("multi_sig").unwrap();

// //         let admin: ContractAddress = contract_address_const::<1>();

// //         let mut calldata = ArrayTrait::new();
// //         admin.serialize(ref calldata);
// //         let (contract_address, _) = contract_class.deploy(@calldata).unwrap();
// //         contract_address
// // }

// // //
// // // upgrade
// // //

// #[test]
// #[should_panic(expected: ('Class hash cannot be zero', 'ENTRYPOINT_FAILED',))]
// fn test_upgrade_with_class_hash_zero() {
//     let v1 = deploy_v1();
//     v1.upgrade(CLASS_HASH_ZERO());
// }

// #[test]
// fn test_upgraded_event() {
//     let v1 = deploy_v1();
//     v1.upgrade(V2_CLASS_HASH());

//     assert_only_event_upgraded(v1.contract_address, V2_CLASS_HASH());
// }

// // #[test]
// // fn test_new_selector_after_upgrade() {
// //     let v1 = deploy_v1();

// //     v1.upgrade(V2_CLASS_HASH());
// //     let v2 = IUpgradesV2Dispatcher { contract_address: v1.contract_address };

// //     v2.set_value2(VALUE);
// //     assert_eq!(v2.get_value2(), VALUE);
// // }

// // #[test]
// // fn test_state_persists_after_upgrade() {
// //     let v1 = deploy_v1();
// //     v1.set_value(VALUE);

// //     v1.upgrade(V2_CLASS_HASH());
// //     let v2 = IUpgradesV2Dispatcher { contract_address: v1.contract_address };

// //     assert_eq!(v2.get_value(), VALUE);
// // }

// // #[test]
// // fn test_remove_selector_passes_in_v1() {
// //     let v1 = deploy_v1();
// //     v1.remove_selector();
// // }

// // #[test]
// // #[should_panic(expected: ('ENTRYPOINT_NOT_FOUND',))]
// // fn test_remove_selector_fails_in_v2() {
// //     let v1 = deploy_v1();
// //     v1.upgrade(V2_CLASS_HASH());
// //     // We use the v1 dispatcher because remove_selector is not in v2 interface
// //     v1.remove_selector();
// // }

// //     #[test]
// //     #[should_panic(expected: ('Restricted to Admin Only',))]
// //     fn test_upgrade_non_admin() {
// //         let contract_address = setup();
// //         let dispatcher = Imulti_sigDispatcher { contract_address };

// //         // Set caller as non-admin
// //         start_cheat_caller_address(contract_address, contract_address_const::<456>());

// //         let new_class_hash = V2_CLASS_HASH();
// //         dispatcher.upgrade(new_class_hash);
// //     }

// //     #[test]
// //     fn test_upgrade_admin() {
// //         let contract_address = setup();
// //         let dispatcher = Imulti_sigDispatcher { contract_address };

// //         // Set caller as admin
// //         start_cheat_caller_address(contract_address, contract_address_const::<123>());

// //         let new_class_hash = V2_CLASS_HASH();
// //         dispatcher.upgrade(new_class_hash);
// //     }