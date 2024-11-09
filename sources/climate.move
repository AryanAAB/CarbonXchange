address 0xd16a6471580aea89231e143bd2962d5d14573432efdfad36eb7585a951ed7f38
{
    module CarbonMarketplace
    {
        use std::signer;
        use 0xd16a6471580aea89231e143bd2962d5d14573432efdfad36eb7585a951ed7f38::ClimateCoin;
        use std::vector;

        const INIT_CARBON_OFFSET: u64 = 100;
        const INIT_COINS: u64 = 100;
        
        struct CarbonOffset has key, store
        {
            amount: u64
        }

        struct Listing has store, drop
        {
            carbon_offset_amount: u64,
            price: u64
        }

        struct Listings has key
        {
            listings: vector<Listing>,
        }

        public fun initialize_account(account: &signer)
        {
            let carbon_offset = CarbonOffset {amount : INIT_CARBON_OFFSET };
            move_to(account, carbon_offset);

            ClimateCoin::mint(account, INIT_COINS);

            let listings = Listings { listings: vector::empty<Listing>() };
            move_to(account, listings);
        }

        public fun create_listing(account: &signer, amount: u64, price: u64) acquires CarbonOffset, Listings 
        {
            let carbon_offset = borrow_global_mut<CarbonOffset>(signer::address_of(account));
            assert!(carbon_offset.amount >= amount, 1);

            carbon_offset.amount = carbon_offset.amount - amount;
            let listing = Listing { carbon_offset_amount: amount, price };

            let listings = borrow_global_mut<Listings>(signer::address_of(account));
            vector::push_back(&mut listings.listings, listing);
        }

        
        public fun buy_offset(buyer: &signer, seller_addr: address, listing_index: u64) acquires CarbonOffset, Listings 
        {
            let seller_listings = borrow_global_mut<Listings>(seller_addr);
            let listing = vector::borrow_mut(&mut seller_listings.listings, listing_index);

            let buyer_balance = ClimateCoin::balance_of(signer::address_of(buyer));
            assert!(buyer_balance >= listing.price, 1);

            ClimateCoin::transfer(buyer, seller_addr, listing.price);

            let buyer_offset = borrow_global_mut<CarbonOffset>(signer::address_of(buyer));
            buyer_offset.amount = buyer_offset.amount + listing.carbon_offset_amount;

            vector::remove(&mut seller_listings.listings, listing_index);
        }
    }
}