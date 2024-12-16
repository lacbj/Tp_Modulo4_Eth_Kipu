//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// Useful for debugging. Remove when deploying to a live network.

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Use openzeppelin to inherit battle-tested implementations (ERC20, ERC721, etc)
// import "@openzeppelin/contracts/access/Ownable.sol";


 
  /// @title Simple Decentralized Exchange (DEX)
/// @notice This contract facilitates token swaps and liquidity management
/// @dev Uses constant product formula for swaps
/// * @author leonel crespo
 

 contract SimpleDEX{
    /// @notice Token A in the liquidity pool
     IERC20 public TokenA;

    /// @notice Token B in the liquidity pool
    IERC20 public TokenB;

  
    event LiquidityAdded(uint256 amountA, uint256 amountB);
    
  
    event LiquidityRemoved(uint256 amountA, uint256 amountB);

    
    event TokenSwapped(address indexed user, uint256 amountIn, uint256 amountOut);

   
    function addLiquidity(uint256 amountA, uint256 amountB) external  {
        require(amountA > 0 && amountB > 0, "Amounts must be > 0");
        TokenA.transferFrom(msg.sender, address(this), amountA);
        TokenB.transferFrom(msg.sender, address(this), amountB);

        emit LiquidityAdded(amountA, amountB);
    }

/// @notice Removes liquidity from the pool
    /// @dev Only callable by the owner
    /// @param amountA The amount of token A to remove
    /// @param amountB The amount of token B to remove
    function removeLiquidity(uint256 amountA, uint256 amountB) external  {
        require(amountA <= TokenA.balanceOf(address(this)) && amountB <= TokenB.balanceOf(address(this)), "Low liquidity");

        TokenA.transfer(msg.sender, amountA);
        TokenB.transfer(msg.sender, amountB);

        emit LiquidityRemoved(amountA, amountB);
    }

    /// @notice Swaps token A for token B
    /// @param amountAIn The amount of token A to swap

    function swapAforB(uint256 amountAIn) external {
        require(amountAIn > 0, "Amount must be > 0");

        uint256 amountBOut = getAmountOut(amountAIn, TokenA.balanceOf(address(this)), TokenB.balanceOf(address(this)));

        TokenA.transferFrom(msg.sender, address(this), amountAIn);
        TokenB.transfer(msg.sender, amountBOut);

        emit TokenSwapped(msg.sender, amountAIn, amountBOut);
    }

    
    function swapBforA(uint256 amountBIn) external {
        require(amountBIn > 0, "Amount must be > 0");

        uint256 amountAOut = getAmountOut(amountBIn, TokenB.balanceOf(address(this)), TokenA.balanceOf(address(this)));

        TokenB.transferFrom(msg.sender, address(this), amountBIn);
        TokenA.transfer(msg.sender, amountAOut);

        emit TokenSwapped(msg.sender, amountBIn, amountAOut);
    }
 

    function getPrice(address _token) external view returns (uint256) {
        require(_token == address( TokenA) || _token == address( TokenB ), "Invalid token");

        return _token == address(TokenA)
            ? (TokenB.balanceOf(address(this)) * 1e18) / TokenA.balanceOf(address(this))
            : (TokenA.balanceOf(address(this)) * 1e18) / TokenB.balanceOf(address(this));
    }



    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) private pure returns (uint256) {
        return (amountIn * reserveOut) / (reserveIn + amountIn);
    }
 }