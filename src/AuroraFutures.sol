pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

/**
@title Aurora Futures Contract
@author Lance Henderson

@notice Contract allows holders of locked tokens to gain liquidity
by minting futures of these tokens which can be traded on the open market.

@dev Mints an ERC20 representing the underlying token deposited in the contract.
Can be redeemed for the underlying token when the maturity date is reached
*/

contract AuroraFutures is ERC20 {

    // Pointer to the underlying ERC20 token
    IERC20 public underlying;
    
    // AuroraFoundation is the address that will deposit aurora tokens
    address public auroraFoundation;

    // Maturity date specifies the date at which locked aurora can be redeemed for aurora tokens
    uint256 public maturityDate;

    // Modifier to ensure caller is auroraFoundation
    modifier onlyFoundation {
        require(msg.sender == auroraFoundation, "Caller must be auroraFoundation");
        _;
    }
    
    /* ========== CONSTRUCTOR ========== */
    
    // @param _maturityDate Date at which futures expire
    // @param _auroraFoundation Address of the aurora foundation
    // @param _name Name of the futures token
    // @param _symbol Symbol of the futures token
    // @param _underlying Underlying token of the contract (aurora)
    // @dev The name and symbol of the token should indicate the maturity date of the token 
    // eg. AURORA_2022_11_18
    constructor(
        uint256 _maturityDate, 
        address _auroraFoundation, 
        string memory _name,
        string memory _symbol,
        address _underlying
   ) ERC20(
        string(_name),
        string(_symbol)
   ){   
        // Check to make sure maturityDate is no more than 5 years
        require(_maturityDate < block.timestamp + (52 weeks * 5), "Maturity date too long");
        maturityDate = _maturityDate;
        auroraFoundation = _auroraFoundation;
        underlying = IERC20(_underlying);
    }
    
    /* ======== RESTRICTED FUNCTIONS ======== */
    
    // Allows auroraFoundation to deposit tokens into the contract
    // An equivalent amount of aurora futures will be minted to their address
    // @dev Prior to calling this function, the sender must give allowance to the contract for transferring the tokens
    function depositUnderlyingTokens(uint256 amount) external onlyFoundation {
        underlying.transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
    }

    /* ========== UNRESTRICTED FUNCTIONS ========== */

    // Allows anyone to redeem their locked aurora for aurora
    function redeemUnderlying(uint256 amount) public {
        require(block.timestamp > maturityDate, "Maturity date not reached");
        _burn(msg.sender, amount);
        underlying.transfer(msg.sender, amount);
    }
    
    // Redeems all future tokens for the underlying aurora
    function redeemAll() external {
        uint256 accountBalance = balanceOf(msg.sender);
        redeemUnderlying(accountBalance);
    }
}
