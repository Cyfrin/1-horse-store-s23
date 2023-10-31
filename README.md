## Compile contract 

To get the raw bytecode of each contract manually:

```
huffc src/huff/HorseStore.huff -b
solc --strict-assembly --optimize --optimize-runs 20000 yul/HorseStoreYul.yul --bin | grep 60 
solc --optimize --optimize-runs 20000 src/HorseStore.sol --bin | grep 60 
solc --optimize --optimize-runs 20000 src/HorseStoreYul.sol --bin | grep 60 
```
