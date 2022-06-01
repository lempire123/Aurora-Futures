# Aurora-Futures

Main contract 'AuroraFutures.sol' can be found within 'src' directory.

**Purpose:**
- Allows holders of vesting tokens to gain liquidity by selling futures on the open market.

**Functionality:**
- The workflow would be the following:
  - Holders deposit vesting tokens into a smart contract, specifying a maturity date
  - The contract mints an equal amount of tokens (futures) which are redeemable for the underlying tokens once the maturity date is reached
  - These futures can then be sold on the open market
