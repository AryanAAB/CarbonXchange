address 0xd16a6471580aea89231e143bd2962d5d14573432efdfad36eb7585a951ed7f38
{
    module ClimateCoin
    {
        use std::signer;
        
        struct ClimateCoin has key, store, copy, drop 
        {
            value: u64,
        }

        // Initializes the ClimateCoin resource for the given account
        public fun initialize(account: &signer) 
        {
            let initial_value = 0u64;
            let coin = ClimateCoin { value: initial_value };
            move_to(account, coin);
        }

        // Mints ClimateCoin to the specified account
        public fun mint(account: &signer, amount: u64) acquires ClimateCoin 
        {
            let coin = borrow_global_mut<ClimateCoin>(signer::address_of(account));
            coin.value = coin.value + amount;
        }

        // Withdraws the specified amount of ClimateCoin from the sender's account
        fun withdraw(sender: &signer, amount: u64): ClimateCoin acquires ClimateCoin 
        {
            let sender_addr = signer::address_of(sender);
            let sender_coin = borrow_global_mut<ClimateCoin>(sender_addr);
            assert!(sender_coin.value >= amount, 1); // Error code 1 for insufficient funds
            sender_coin.value = sender_coin.value - amount;
            ClimateCoin { value: amount }
        }

        // Deposits the specified amount of ClimateCoin into the receiver's account
        fun deposit(receiver_addr: address, coin: ClimateCoin) acquires ClimateCoin 
        {
            let receiver_coin = borrow_global_mut<ClimateCoin>(receiver_addr);
            receiver_coin.value = receiver_coin.value + coin.value;
        }

        // Transfers the specified amount of ClimateCoin from the sender to the receiver
        public fun transfer(sender: &signer, receiver_addr: address, amount: u64) acquires ClimateCoin 
        {
            let coin = withdraw(sender, amount);
            deposit(receiver_addr, coin);
        }

        // Returns the balance of ClimateCoin for the given account
        public fun balance_of(account: address): u64 acquires ClimateCoin 
        {
            let coin = borrow_global<ClimateCoin>(account);
            coin.value
        }
    }
}