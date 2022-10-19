_Stratton Backend_
==================

Description
-----------

This repository serves as the backend for the [Stratton Nodes Presale Repository](https://github.com/Roaring30s/stratton-nodes-presale)

The contracts found here are meant to support the Pbwd.sol contract which serves as the token contract and StrattonPresale.sol which is the smart contract faciliating the overall presale by administering a start and end time, calculating eligible balance per investor, etc.

**Challenges:** These were my first solidity smart contracts. Enough said.

**Technologies:** Solidity

How to use:
-----------

The contracts serve as a good template for future initial coin offerings. The settings in the frontend repo are set to work in the Fuji testnet which will prevent anyone from putting real money in real contracts.

How to run:
-----------

clone + npx hardhat run "path-to-deploy-script"
