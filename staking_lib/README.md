# `staking_lib`

This folder contains the source code for the cli and the blockchain.

## Usage

The following files are useful while using this project.

### 1. `create_account.dart`

This script creates valid private/public key values and automatically generates
a png for each public key for a simpler transaction with the app. 

**Params:** `dart create_account.dart <name 1> ...`

**Output:** `<name 1>.json`and `<name 1>-pub.png`
### 2. `client.dart`

**Params:** `dart client.dart <name 1> <chain name>`

Opens the chain at `<chain name>.json` for user with public/private key in
 `<name 1>.json`. Prompts the user to either send some balance or read out the balance.

 ### 3.  `node.dart`

**Params:** `dart node.dart <name 1> <chain name>`

Opens the chain of `<chain name>.json` as `<name 1>.json`  priv/pubkey and 
broadcasts them to the network. For usage together with flutter-app.