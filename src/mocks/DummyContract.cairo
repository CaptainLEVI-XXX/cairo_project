use starknet::ContractAddress;
#[starknet::interface]
pub trait IDummyContract<TContractState> {
    fn add_owner(ref self: TContractState, new_owner_: ContractAddress);
    fn remove_owner(ref self: TContractState,remove_owner: ContractAddress);
    fn transfer_signature(ref self: TContractState, new_owner_: ContractAddress);
    fn is_owner(self: @TContractState, caller: ContractAddress) -> bool;
    fn required_owners(self: @TContractState) -> u256;
    fn admin_of_wallet(self: @TContractState) -> ContractAddress;
    fn total_owners_of_Wallet(self: @TContractState)->u256;
}

#[starknet::contract]
    mod DummyContract {
        use cairo_wallet::access_registry::Access_registrable;
        use cairo_wallet::access_registry::IAccess_registrable;
        use starknet::ContractAddress;
        use starknet::ClassHash;
        use cairo_wallet::access_registry::Access_registrable::Access_registrable_PrivateImpl;

        component!(path: Access_registrable, storage: access_registrable, event: AccessRegistrableEvent);

        #[storage]
        struct Storage {
            #[substorage(v0)]
            access_registrable: Access_registrable::Storage,
        }
        // const TEST_CLASS_HASH: ByteArray = ByteArray { data: 0x123456 };

        #[event]
        #[derive(Drop, starknet::Event)]
        enum Event {
            #[flat]
            AccessRegistrableEvent: Access_registrable::Event
        }

        #[constructor]
        fn constructor(ref self: ContractState, admin: ContractAddress) {
            self.access_registrable._init(admin);
        }

        #[abi(embed_v0)]
        impl DummyAccessRegistrable of super::IDummyContract<ContractState> {
            fn add_owner(ref self: ContractState, new_owner_: ContractAddress) {
                self.access_registrable.add_owner(new_owner_)
            }

            fn remove_owner(ref self: ContractState,remove_owner:ContractAddress) {
                self.access_registrable.remove_owner(remove_owner)
            }

            fn transfer_signature(ref self: ContractState, new_owner_: ContractAddress) {
                self.access_registrable.transfer_signature(new_owner_)
            }

            fn is_owner(self: @ContractState, caller: ContractAddress) -> bool {
                self.access_registrable.is_owner(caller)
            }

            fn required_owners(self: @ContractState) -> u256 {
                self.access_registrable.required_owners()
            }

            fn admin_of_wallet(self: @ContractState) -> ContractAddress {
                self.access_registrable.admin_of_wallet()
            }
            fn total_owners_of_Wallet(self: @ContractState)->u256{
                self.access_registrable.total_owners_of_Wallet()
            }
        }
    }