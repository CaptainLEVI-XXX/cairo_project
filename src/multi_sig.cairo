use core::starknet::contract_address::ContractAddress;
use super::access_registry::Access_registrable_component;


#[derive(Drop, Serde)]
pub struct Transaction{
    pub from : ContractAddress,
    pub to : ContractAddress,
    pub data: felt252,
    pub value: u256,
    pub number_of_conformation: u256,
    pub is_executed: bool
}

#[starknet::interface]
pub trait Imulti_sig<TContractState>{

    fn create_tx(
        ref self: TContractState, to: ContractAddress, value: u256, data:felt252
    );
    fn approve_tx(ref self: TContractState, _tx_id: u256);
    fn re_approve_tx(ref self: TContractState, _tx_id: u256);
    fn execute_tx(ref self:TContractState,_tx_id: u256);

    fn get_tx_details(self: @TContractState,_tx_id:u256)->Transaction;
    fn tx_exist(self: @TContractState, _tx_id:u256)->bool;
    fn tx_executed(self: @TContractState,_tx_id:u256 )->bool;

}

#[starknet::contract]
pub mod multi_sig{
    use starknet::{
        ContractAddress,get_caller_address
    };
    use super::Access_registrable_component;
    use super::Transaction;
    use super::Access_registrable_component::Access_registrable_PrivateImpl;

    component!(path: Access_registrable_component, storage: Access_registrable_storage, event : Access_registrable_events);
    
    #[abi(embed_v0)]
    impl Access_registrableImpl = Access_registrable_component::Access_registrable<ContractState>;


    #[storage]
    struct Storage{
        
        tx_id: u256,
        transactions: LegacyMap::<u256,Transaction>,
        is_approved_transaction: LegacyMap::< (u256,ContractAddress),bool>,
        executed_transactions: LegacyMap::<u256,bool>, 

        #[substorage(v0)]
        Access_registrable_storage : Access_registrable_component::Storage

    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {

        event_tx_created: event_tx_created,
        event_tx_Approved: event_tx_Approved,
        event_tx_re_approved: event_tx_re_approved,
        event_tx_executed: event_tx_executed,
        
        #[flat]
        Access_registrable_events: Access_registrable_component::Event
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

    // impl Access_registrable_PrivateImpl = Access_registrable_component::Access_registrable_PrivateImpl;


    #[constructor]
    fn constructor(ref self: ContractState, admin_: ContractAddress) {
        self.Access_registrable_storage._init(admin_);
    }

    #[abi(embed_v0)]
    impl multi_sig of super::Imulti_sig<ContractState>{

        fn create_tx(ref self: ContractState, to: ContractAddress, value: u256, data:felt252){
            
            let caller =get_caller_address();
            let tx_id = self.tx_id.read();
            assert(self.Access_registrable_storage.is_owner(caller)==true,'Not the Owner');
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
            assert(self.Access_registrable_storage.is_owner(caller)==true,'Not the Owner');
            assert(!self.is_approved_transaction.read((_tx_id,caller)),'Already Approved');
            assert(self.tx_exist(_tx_id) && self.tx_executed(_tx_id),'tx not Valid');

            self.is_approved_transaction.write((_tx_id,caller),true);
            let mut transaction : Transaction = self.transactions.read(_tx_id);
            transaction.number_of_conformation+=1;
            self.transactions.write(_tx_id,transaction);
        }
        fn re_approve_tx(ref self: ContractState, _tx_id:u256){

            let caller = get_caller_address();
            assert(self.Access_registrable_storage.is_owner(caller)==true,'Not the Owner');
            assert(self.is_approved_transaction.read((_tx_id,caller)),'Already Not Approved');
            assert(self.tx_exist(_tx_id) && self.tx_executed(_tx_id),'tx not Valid');

            self.is_approved_transaction.write((_tx_id,caller),false);
            let mut transaction : Transaction = self.transactions.read(_tx_id);
            transaction.number_of_conformation-=1;
            self.transactions.write(_tx_id,transaction);
        }
        fn execute_tx(ref self:ContractState,_tx_id: u256){
            assert(self.tx_exist(_tx_id) && !self.tx_executed(_tx_id),'Error');
            let required_owners = self.Access_registrable_storage.number_of_owners_required.read();
            let count_approval = self.transactions.read(_tx_id).number_of_conformation;
            assert(count_approval >= required_owners,'Not Enough Approval');
            //INCOMPLETE



        }
        fn get_tx_details(self: @ContractState, _tx_id:u256)->Transaction{
            assert(self.tx_exist(_tx_id) && !self.tx_executed(_tx_id),'Error');
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