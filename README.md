<p align="center">
<img src="./images/horse-store.png" width="400" alt="horse-store">
<br/>

# Horse Store 

This is *not* an audit. This is the codebase of the course for you to learn how compilers and opcodes work. We will be dissecting contracts that you build and tinker with. 

We will be using huff, solidity, and yul to do so.

We are also (later) going to use this repo to understand the basics of formal verification. 

# Getting Started

## Requirements

-   [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)  
    -   You'll know you've done it right if you can run `git --version`
-   [Foundry / Foundryup](https://github.com/gakonst/foundry)
    -   This will install `forge`, `cast`, and `anvil`
    -   You can test you've installed them right by running `forge --version` and get an output like: `forge 0.2.0 (f016135 2022-07-04T00:15:02.930499Z)`
    -   To get the latest of each, just run `foundryup`
-   [Huff Compiler](https://docs.huff.sh/get-started/installing/)
    -   You'll know you've done it right if you can run `huffc --version` and get an output like: `huffc 0.2.0`
-   [Solidity Compiler](https://docs.soliditylang.org/en/latest/installing-solidity.html)
    -   You'll know you've done it right if you can run `solc --verison` and get an output like:
    -   `solc, the solidity compiler commandline interface Version: 0.8.15+commit.e14f2714.Darwin.appleclan`
-   [Halmos (which means you need python)](https://github.com/a16z/halmos)
    -   You'll know you've done it right if you can run `halmos --version` and get an output like: `Halmos 0.1.9`


## Quickstart

1. Clone the repo & install dependencies

```
git clone https://github.com/Cyfrin/10-horse-store-s23
cd 10-horse-store-s23
make
```

2. Run tests

```
forge test
```

# Use

## Compile contracts 

To get the raw bytecode of each contract manually:

To get the exact same as what I get, you'll need to use solc version `Version: 0.8.20+commit.a1b79de6.Darwin.appleclang`. 

```
huffc src/huff/HorseStore.huff -b
solc --strict-assembly --optimize --optimize-runs 20000 yul/HorseStoreYul.yul --bin | grep 60 
solc --optimize --optimize-runs 20000 src/HorseStore.sol --bin | grep 60 
solc --optimize --optimize-runs 20000 src/HorseStoreYul.sol --bin | grep 60 
```
