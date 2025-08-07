module vault_manager::VaultManager {
    use std::error;
    use std::signer;
    use std::coin::{Self, AptosCoin};
    use std::event;
    use std::vector;
    use std::address;

    const E_NOT_ADMIN: u64 = 0;
    const E_NOT_ENOUGH_BALANCE: u64 = 1;
    const E_NOT_ALLOCATED: u64 = 2;

    struct TokensDepositedEvent has copy, drop, store {
        amount: u64,
    }

    struct TokensAllocatedEvent has copy, drop, store {
        recipient: address,
        amount: u64,
    }

    struct TokensClaimedEvent has copy, drop, store {
        recipient: address,
        amount: u64,
    }

    struct Vault has key {
        admin: address,
        vault_address: address,
        total_balance: u64,
        allocations: vector<(address, u64)>,
        tokens_deposited_events: event::EventHandle<TokensDepositedEvent>,
        tokens_allocated_events: event::EventHandle<TokensAllocatedEvent>,
        tokens_claimed_events: event::EventHandle<TokensClaimedEvent>,
    }

    public entry fun init_module(admin: &signer) {
        let admin_address = signer::address_of(admin);
        let vault = Vault {
            admin: admin_address,
            vault_address: admin_address,
            total_balance: 0,
            allocations: vector::empty(),
            tokens_deposited_events: event::new_event_handle<TokensDepositedEvent>(admin),
            tokens_allocated_events: event::new_event_handle<TokensAllocatedEvent>(admin),
            tokens_claimed_events: event::new_event_handle<TokensClaimedEvent>(admin),
        };
        move_to(admin, vault);
    }

    public entry fun deposit_tokens(admin: &signer, vault_address: address, amount: u64) acquires Vault {
        let vault = borrow_global_mut<Vault>(vault_address);
        assert!(vault.admin == signer::address_of(admin), error::invalid_argument(E_NOT_ADMIN));
        coin::transfer<AptosCoin>(admin, vault.vault_address, amount);
        vault.total_balance = vault.total_balance + amount;
        event::emit_event(&mut vault.tokens_deposited_events, TokensDepositedEvent { amount });
    }

    public entry fun allocate_tokens(admin: &signer, vault_address: address, recipient: address, amount: u64) acquires Vault {
        let vault = borrow_global_mut<Vault>(vault_address);
        assert!(vault.admin == signer::address_of(admin), error::invalid_argument(E_NOT_ADMIN));
        assert!(vault.total_balance >= amount, error::invalid_argument(E_NOT_ENOUGH_BALANCE));
        vector::push_back(&mut vault.allocations, (recipient, amount));
        event::emit_event(&mut vault.tokens_allocated_events, TokensAllocatedEvent { recipient, amount });
    }

    public entry fun claim_tokens(claimant: &signer, vault_address: address) acquires Vault {
        let claimant_address = signer::address_of(claimant);
        let vault = borrow_global_mut<Vault>(vault_address);
        let mut i = 0;
        let mut found = false;
        let mut amount = 0;
        let len = vector::length(&vault.allocations);
        while (i < len) {
            let (addr, amt) = *vector::borrow(&vault.allocations, i);
            if (addr == claimant_address) {
                found = true;
                amount = amt;
                vector::swap_remove(&mut vault.allocations, i);
                break;
            };
            i = i + 1;
        };
        assert!(found, error::invalid_argument(E_NOT_ALLOCATED));
        vault.total_balance = vault.total_balance - amount;
        coin::transfer<AptosCoin>(&vault.vault_address, claimant_address, amount);
        event::emit_event(&mut vault.tokens_claimed_events, TokensClaimedEvent { recipient: claimant_address, amount });
    }

    public entry fun withdraw_tokens(admin: &signer, vault_address: address, amount: u64) acquires Vault {
        let vault = borrow_global_mut<Vault>(vault_address);
        assert!(vault.admin == signer::address_of(admin), error::invalid_argument(E_NOT_ADMIN));
        assert!(vault.total_balance >= amount, error::invalid_argument(E_NOT_ENOUGH_BALANCE));
        vault.total_balance = vault.total_balance - amount;
        coin::transfer<AptosCoin>(&vault.vault_address, signer::address_of(admin), amount);
    }

    public fun view_total_balance(vault_address: address): u64 acquires Vault {
        borrow_global<Vault>(vault_address).total_balance
    }
}
