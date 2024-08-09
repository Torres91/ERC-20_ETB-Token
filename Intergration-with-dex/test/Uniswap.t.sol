// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";
import {IUniswapV2Router02} from "uniswap-v2-periphery/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "uniswap-v2-core/interfaces/IUniswapV2Factory.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "forge-std/console.sol";

contract CounterTest is Test {
    Token public token;

    // IUniswapV2Router02 public _uniswapV2Router =
    //     IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // mainnet Uniswap address

    IUniswapV2Router02 public _uniswapV2Router =
        IUniswapV2Router02(0xeaBcE3E74EF41FB40024a21Cc2ee2F5dDc615791); // sepolia SushiSwap address

    address public uniswapV2Pair;

    uint256 initialTotalSupply = 1_000_000 ether;
    uint256 initialEthSupply = 2500 ether;
    address owner = address(1);

    function setUp() public {
        token = new Token(owner);
    }

    function test_Uniswap_CreatingPair() public {
        address tokenAddress = address(token);
        address wethAddress = _uniswapV2Router.WETH();
        IUniswapV2Factory factory = IUniswapV2Factory(
            _uniswapV2Router.factory()
        );
        uniswapV2Pair = factory.createPair(tokenAddress, wethAddress);

        assertNotEq(uniswapV2Pair, address(0));
    }

    function test_Uniswap_AddingLiquidity() public {
        deal(owner, initialEthSupply);

        vm.startPrank(owner);
        token.mint(owner, initialTotalSupply);
        token.approve(address(_uniswapV2Router), initialTotalSupply);

        address tokenAddress = address(token);
        address wethAddress = _uniswapV2Router.WETH();
        IUniswapV2Factory factory = IUniswapV2Factory(
            _uniswapV2Router.factory()
        );
        uniswapV2Pair = factory.createPair(tokenAddress, wethAddress);

        uint256 tokenBalance = IERC20(token).balanceOf(owner);
        uint256 ethBalance = owner.balance;
        uint256 lpBalance = IERC20(uniswapV2Pair).balanceOf(owner);
        console.log(
            "------------------------------------------------------------"
        );
        console.log("Start tokenBalance:   ", tokenBalance);
        console.log("Start ethBalance:   ", ethBalance);
        console.log("Start lpBalance:   ", lpBalance);

        _uniswapV2Router.addLiquidityETH{value: initialEthSupply}(
            address(token),
            initialTotalSupply,
            0,
            0,
            owner,
            block.timestamp
        );

        tokenBalance = IERC20(token).balanceOf(owner);
        ethBalance = owner.balance;
        lpBalance = IERC20(uniswapV2Pair).balanceOf(owner);

        console.log(
            "------------------------------------------------------------"
        );
        console.log("After liquidity added tokenBalance:   ", tokenBalance);
        console.log("After liquidity added ethBalance:   ", ethBalance);
        console.log("After liquidity added lpBalance:   ", lpBalance);

        assertEq(tokenBalance, 0);
        assertEq(ethBalance, 0);
        assertGt(lpBalance, 0);
    }

    function test_Uniswap_AddingAndRemovingLiquidity() public {
        deal(owner, initialEthSupply);

        vm.startPrank(owner);
        token.mint(owner, initialTotalSupply);
        token.approve(address(_uniswapV2Router), initialTotalSupply);

        address tokenAddress = address(token);
        address wethAddress = _uniswapV2Router.WETH();
        IUniswapV2Factory factory = IUniswapV2Factory(
            _uniswapV2Router.factory()
        );
        uniswapV2Pair = factory.createPair(tokenAddress, wethAddress);

        uint256 tokenBalance = IERC20(token).balanceOf(owner);
        uint256 ethBalance = owner.balance;
        uint256 lpBalance = IERC20(uniswapV2Pair).balanceOf(owner);
        console.log(
            "------------------------------------------------------------"
        );
        console.log("Start tokenBalance:   ", tokenBalance);
        console.log("Start ethBalance:   ", ethBalance);
        console.log("Start lpBalance:   ", lpBalance);

        _uniswapV2Router.addLiquidityETH{value: initialEthSupply}(
            address(token),
            initialTotalSupply,
            0,
            0,
            owner,
            block.timestamp
        );

        tokenBalance = IERC20(token).balanceOf(owner);
        ethBalance = owner.balance;
        lpBalance = IERC20(uniswapV2Pair).balanceOf(owner);

        console.log(
            "------------------------------------------------------------"
        );
        console.log("After liquidity added tokenBalance:   ", tokenBalance);
        console.log("After liquidity added ethBalance:   ", ethBalance);
        console.log("After liquidity added lpBalance:   ", lpBalance);

        assertEq(tokenBalance, 0);
        assertEq(ethBalance, 0);
        assertGt(lpBalance, 0);

        IERC20(uniswapV2Pair).approve(address(_uniswapV2Router), lpBalance);
        (uint amountA, uint amountB) = _uniswapV2Router.removeLiquidityETH(
            address(token),
            lpBalance,
            0,
            0,
            owner,
            block.timestamp
        );
        console.log(
            "------------------------------------------------------------"
        );
        console.log("Returned amountA:   ", amountA);
        console.log("Returned amountB:   ", amountB);

        tokenBalance = IERC20(token).balanceOf(owner);
        ethBalance = owner.balance;
        lpBalance = IERC20(uniswapV2Pair).balanceOf(owner);

        console.log(
            "------------------------------------------------------------"
        );
        console.log("After liquidity removed tokenBalance:   ", tokenBalance);
        console.log("After liquidity removed ethBalance:   ", ethBalance);
        console.log("After liquidity removed lpBalance:   ", lpBalance);
        console.log(
            "------------------------------------------------------------"
        );

        assertEq(tokenBalance, amountA);
        assertEq(ethBalance, amountB);
        assertEq(lpBalance, 0);
    }
}
