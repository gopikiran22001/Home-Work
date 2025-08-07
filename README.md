# 🧠 Aptos Vault Contract Optimization - Homework Submission

## 📘 Overview

This project is a modified version of the Aptos Vault smart contract. The core improvement focuses on **optimizing the contract's efficiency** by **eliminating unnecessary address derivation** logic. Instead of passing the `admin_address` and using `get_vault_address`, we now directly pass the `vault_address` to relevant functions.

---

## ✨ Objectives

- Replace indirect vault address resolution with direct vault address usage.
- Refactor all entry and view functions to use `vault_address`.
- Preserve access control and logic integrity.
- Deploy and test the optimized contract on Aptos Devnet using Remix IDE + Welldone Wallet.

---

## 🔧 Changes Made

### ✅ Code Refactor

- ❌ Removed: `get_vault_address(admin_address)` function.
- ✅ Updated Function Signatures:
  - `deposit_tokens(admin, vault_address, amount)`
  - `allocate_tokens(admin, vault_address, recipient, amount)`
  - `withdraw_tokens(admin, vault_address, amount)`
  - `claim_tokens(user, vault_address)`
- ✅ Access Check Logic:
  - Replaced `signer::address_of(admin) == admin_address`
  - Now checks `vault.admin == signer::address_of(admin)`

---

## 📦 Deployment

- ✅ Contract deployed using Remix IDE and Welldone Wallet.
- ✅ Deployed on Aptos Devnet.
- 🏗️ Contract Address: `0xYOUR_DEPLOYED_ADDRESS_HERE` *(replace with actual)*

---

## 🧪 Testing Summary

### 🔹 Test Cases Executed

1. ✅ **Initialize Vault**  
2. ✅ **Deposit Tokens**  
3. ✅ **Allocate Tokens**  
4. ✅ **Claim Allocated Tokens**  
5. ✅ **Withdraw Unallocated Tokens**  
6. ✅ **Unauthorized Allocation (expected fail)**  
7. ✅ **Unauthorized Withdraw (expected fail)**  

---

## 🚧 Challenges Faced

- Ensured admin validation logic remained robust after removing indirection.
- Carefully modified all references to avoid breaking vault references.
- Tested full contract lifecycle via Remix to ensure complete coverage.

---

## 🔭 Future Scope

- Add more granular role-based access control.
- Expand token support beyond AptosCoin.
- Improve error messaging for better UX.

---

## ✍️ Author

**Name**: Gopi Kiran  
**Bootcamp**: Aptos Blockchain Bootcamp  
**Date**: August 2025

---

