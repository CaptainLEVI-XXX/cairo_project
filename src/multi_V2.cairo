use core::starknet::contract_address::ContractAddress;
use super::access_registry::Access_registrable;
use core::starknet::Store;
use starknet::ClassHash;


#[derive(Drop, Serde,starknet::Store)]
pub struct Transaction{
    pub from : ContractAddress,
    pub to : ContractAddress,
    pub data: felt252,
    pub value: u256,
    pub number_of_conformation: u256,
    pub is_executed: bool
}

#[starknet::interface]
pub trait Imulti_V2<TContractState>{

    fn upgrade(ref self: TContractState, new_class_hash: ClassHash);

    fn read_total_tx_id(self:@TContractState)->u256;
    fn create_tx(ref self: TContractState, to: ContractAddress, value: u256, data:felt252);
    fn approve_tx(ref self: TContractState, _tx_id: u256);
    fn re_approve_tx(ref self: TContractState, _tx_id: u256);
    fn execute_tx(ref self:TContractState,_tx_id: u256);

    fn get_tx_details(self: @TContractState,_tx_id:u256)->Transaction;
    fn tx_exist(self: @TContractState, _tx_id:u256)->bool;
    fn tx_executed(self: @TContractState,_tx_id:u256 )->bool;

}

#[starknet::contract]
pub mod multi_V2{
    use starknet::{
        ContractAddress,get_caller_address,ClassHash
    };
    use super::Access_registrable;
    use super::Transaction;
    use core::num::traits::Zero;
    use super::Access_registrable::Access_registrable_PrivateImpl;
    use openzeppelin::upgrades::UpgradeableComponent;
    use openzeppelin::upgrades::interface::IUpgradeable;

    component!(path: Access_registrable, storage: Access_registrable_storage, event : Access_registrable_events);
    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);
    
    #[abi(embed_v0)]
    impl Access_RegistrableImpl = Access_registrable::Access_Registrable<ContractState>;
    /// Upgradeable
    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;



    #[storage]
    struct Storage{
        
        tx_id: u256,
        transactions: LegacyMap::<u256,Transaction>,
        is_approved_transaction: LegacyMap::< (u256,ContractAddress),bool>,
        executed_transactions: LegacyMap::<u256,bool>, 
        #[substorage(v0)]
        Access_registrable_storage : Access_registrable::Storage,
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage

    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        event_tx_created: event_tx_created,
        event_tx_Approved: event_tx_Approved,
        event_tx_re_approved: event_tx_re_approved,
        event_tx_executed: event_tx_executed,
        #[flat]
        Access_registrable_events: Access_registrable::Event,
        #[flat]
        UpgradeableEvent: UpgradeableComponent::Event
    }

    #[derive(Drop, starknet::Event)]
    pub struct event_tx_created{
        from: ContractAddress,
        to:ContractAddress,
        value: u256,
        #[key]
        tx_Id: u256,
        data: felt252
    }

    #[derive(Drop, starknet::Event)]
    pub struct event_tx_Approved  {
        approver: ContractAddress,
        tx_Id :u256
    }

    #[derive(Drop, starknet::Event)]
    pub struct event_tx_re_approved{
        revoker: ContractAddress,
        tx_Id :u256

    }

    #[derive(Drop, starknet::Event)]
    pub struct event_tx_executed{
        tx_Id: u256
    }

    pub mod Errors {
        pub const NOT_OWNER: felt252 = 'Caller is not the owner';
        pub const ALREADY_OWNER: felt252 = 'Caller is Already owner';
        pub const ZERO_ADDRESS_CALLER: felt252 = 'Caller is the zero address';
        pub const NOT_ENOUGH_APPROVAL: felt252 = 'not enough approval for tx';
        pub const TX_NOT_EXIST_OR_ALREADY_EXECUTED: felt252 ='tx not exit or already executed';
        pub const TX_NOT_EXIST: felt252 = 'tx not exit';
        pub const TX_ALREADY_EXECUTED: felt252 ='tx already executed';
        pub const TX_ALREADY_APPROVED: felt252 ='tx already approved';
        pub const TX_ALREADY_NOT_APPROVED: felt252 ='tx already not approved';
    }


    #[constructor]
    fn constructor(ref self: ContractState, admin_: ContractAddress) {
        self.Access_registrable_storage._init(admin_);
    }

    #[abi(embed_v0)]
    impl multi_V2 of super::Imulti_V2<ContractState>{

        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            // This function can only be called by the owner
            assert(self.Access_registrable_storage.admin_of_wallet()==get_caller_address(),'Restricted to Admin Only');
            // Replace the class hash upgrading the contract
            self.upgradeable.upgrade(new_class_hash);
        }

        fn read_total_tx_id(self:@ContractState)->u256{
            self.tx_id.read()
        }

        fn create_tx(ref self: ContractState, to: ContractAddress, value: u256, data:felt252){
            
            let caller =get_caller_address();
            let tx_id = self.tx_id.read();
            assert(self.Access_registrable_storage.is_owner(caller)==true,Errors::NOT_OWNER);
            self.transactions.write(
                tx_id,
                Transaction{
                        from: caller,
                        to: to,
                        data: data,
                        value: value,
                        number_of_conformation: 0,
                        is_executed: false }
                );
            self.emit(Event::event_tx_created(event_tx_created{
                        from: caller,
                        to: to,
                        value: value,
                        tx_Id: tx_id,
                        data: data 
            }));

            self.tx_id.write(tx_id+1);

        }
        fn approve_tx(ref self: ContractState, _tx_id:u256){

            let caller = get_caller_address();
            assert(self.Access_registrable_storage.is_owner(caller)==true,Errors::NOT_OWNER);
            assert(!self.is_approved_transaction.read((_tx_id,caller)),Errors::TX_ALREADY_APPROVED);
            assert(self.tx_exist(_tx_id) && self.tx_executed(_tx_id),Errors::TX_NOT_EXIST_OR_ALREADY_EXECUTED);

            self.is_approved_transaction.write((_tx_id,caller),true);
            let mut transaction : Transaction = self.transactions.read(_tx_id);
            transaction.number_of_conformation+=1;
            self.transactions.write(_tx_id,transaction);
        }
        fn re_approve_tx(ref self: ContractState, _tx_id:u256){

            let caller = get_caller_address();
            assert(self.Access_registrable_storage.is_owner(caller)==true,Errors::NOT_OWNER);
            assert(self.is_approved_transaction.read((_tx_id,caller)),Errors::TX_ALREADY_NOT_APPROVED);
            assert(self.tx_exist(_tx_id) && self.tx_executed(_tx_id),Errors::TX_NOT_EXIST_OR_ALREADY_EXECUTED);

            self.is_approved_transaction.write((_tx_id,caller),false);
            let mut transaction : Transaction = self.transactions.read(_tx_id);
            transaction.number_of_conformation-=1;
            self.transactions.write(_tx_id,transaction);
        }
        fn execute_tx(ref self:ContractState,_tx_id: u256){
            assert(self.tx_exist(_tx_id) && !self.tx_executed(_tx_id),Errors::TX_NOT_EXIST_OR_ALREADY_EXECUTED);
            let required_owners = self.Access_registrable_storage.number_of_owners_required.read();
            let count_approval = self.transactions.read(_tx_id).number_of_conformation;
            assert(count_approval >= required_owners,Errors::NOT_ENOUGH_APPROVAL);
            self.executed_transactions.write(_tx_id,true);
            self.transactions.write(
                _tx_id,
                Transaction{
                        from:Zero::zero(),
                        to: Zero::zero(),
                        data: 0,
                        value: 0,
                        number_of_conformation: 0,
                        is_executed: false }
                    );

        }
        fn get_tx_details(self: @ContractState, _tx_id:u256)->Transaction{
            assert(self.tx_exist(_tx_id) && !self.tx_executed(_tx_id),' error');
            self.transactions.read(_tx_id) 
        }
        fn tx_exist(self: @ContractState, _tx_id:u256)->bool{
            if _tx_id>=0 && _tx_id< self.tx_id.read(){
                return true;
            }
            false
        }
        fn tx_executed(self: @ContractState,_tx_id:u256 )->bool{
            
            if self.executed_transactions.read(_tx_id){
                return true;
            }
            false
        }

    }
}

