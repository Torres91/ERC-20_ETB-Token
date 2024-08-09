// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IToken} from "./IToken.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ICO is Ownable {
    using Address for address payable;
    using SafeERC20 for IERC20;

    IToken public token;
    uint256 public rate;
    uint256 public startTime;
    uint256 public endTime;
    uint256 totalTokensPurchased;
    bool public icoClosed;

    event TokensPurchased(address indexed purchaser, uint256 amount);
    event TokensClaimed(address indexed purchaser, uint256 amount);
    event Withdrawn();
    event IcoEnded();

    error IcoAlreadyClosed();
    error IcoNotClosedYet();
    error IcoIsNotActive();
    error InvalidAmount();

    mapping(address => uint256) public userBalance;

    constructor(
        address _tokenAddress,
        uint256 _rate,
        uint256 _startTime,
        uint256 _endTime
    ) Ownable(msg.sender) {
        token = IToken(_tokenAddress);
        rate = _rate;
        startTime = _startTime;
        endTime = _endTime;
    }

    function buyTokens() public payable {
        _ensureIcoIsInStatus(true);
        if (startTime > block.timestamp || block.timestamp > endTime) {
            revert IcoIsNotActive();
        }

        if (msg.value % rate != 0) {
            revert InvalidAmount();
        }

        uint256 tokenAmount = msg.value * rate;
        userBalance[msg.sender] += tokenAmount;
        totalTokensPurchased += tokenAmount;
        emit TokensPurchased(msg.sender, tokenAmount);
    }

    function withdrawFunds() external onlyOwner {
        _ensureIcoIsInStatus(true);

        uint256 balance = address(this).balance;
        payable(owner()).sendValue(balance);
        emit Withdrawn();
    }

    function claimTokens() external {
        _ensureIcoIsInStatus(true);

        uint256 tokenAmount = userBalance[msg.sender];
        require(tokenAmount > 0);
        delete userBalance[msg.sender];
        IERC20(token).safeTransfer(msg.sender, tokenAmount);
        emit TokensClaimed(msg.sender, tokenAmount);
    }

    function closeIco() external onlyOwner {
        _ensureIcoIsInStatus(false);

        icoClosed = true;
        token.mint(address(this), totalTokensPurchased);
        token.renounceOwnership();
        emit IcoEnded();
    }

    function _ensureIcoIsInStatus(bool isClosed) internal view {
        if (isClosed && !icoClosed) {
            revert IcoNotClosedYet();
        } else if (!isClosed && icoClosed) {
            revert IcoAlreadyClosed();
        }
    }
}
