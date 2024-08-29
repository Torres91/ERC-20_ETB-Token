// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Token} from "../src/Token.sol";
import {Script, console} from "forge-std/Script.sol";
import {IUniswapV2Router02} from "uniswap-v2-periphery/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "uniswap-v2-core/interfaces/IUniswapV2Factory.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenScript is Script {
    Token token;

    address owner = address(0xd394FD9EBD018aCc161823De1EEdc5fE951c8D1C);

    IUniswapV2Router02 public _uniswapV2Router =
        IUniswapV2Router02(0xeaBcE3E74EF41FB40024a21Cc2ee2F5dDc615791); // sepolia address
    address public uniswapV2Pair;
    uint256 initialTotalSupply = 1_000_000 ether;
    uint256 initialEthSupply = 0.1 ether;

    address burn = 0x000000000000000000000000000000000000dEaD;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // Deploy token
        token = new Token(owner);
        // Mint initial total supply
        token.mint(owner, initialTotalSupply);
        // Approve Router to spend our tokens
        token.approve(address(_uniswapV2Router), initialTotalSupply);

        // Get our token address
        address tokenAddress = address(token);
        // Get WETH token address from Router
        address wethAddress = _uniswapV2Router.WETH();
        // Get the factory
        IUniswapV2Factory factory = IUniswapV2Factory(
            _uniswapV2Router.factory()
        );
        // Create pair of Our token/WETH
        uniswapV2Pair = factory.createPair(tokenAddress, wethAddress);

        // Add liquidity to pool
        _uniswapV2Router.addLiquidityETH{value: initialEthSupply}(
            address(token),
            initialTotalSupply,
            0, // Set to 0 for simplicity, should be estimated properly to handle slippage
            0, // Set to 0 for simplicity, should be estimated properly to handle slippage
            owner,
            block.timestamp + 2 minutes
        );

        // Burn LP tokens
        // IERC20(uniswapV2Pair).transfer(
        //     burn,
        //     IERC20(uniswapV2Pair).balanceOf(owner)
        // );
        uint256 lpBalance = IERC20(uniswapV2Pair).balanceOf(owner);

        IERC20(uniswapV2Pair).transfer(burn, lpBalance);

        vm.stopBroadcast();
    }
}
