#[starknet::contract]
pub mod MockContract {
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

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        AccessRegistrableEvent: Access_registrable::Event
    }
    #[constructor]
    fn constructor(ref self: ContractState, admin: ContractAddress) {
            self.access_registrable._init(admin);
    }

    #[abi(embed_v0)]
    impl Access_Registrable = Access_registrable::Access_Registrable<ContractState>;
}