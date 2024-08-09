// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Airdrop is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public token;

    event TokensAirdropped(address indexed user, uint256 amount);

    constructor(address _tokenAddress) Ownable(msg.sender) {
        token = IERC20(_tokenAddress);
    }

    function airdrop(
        address[] calldata users,
        uint256[] calldata amounts
    ) public {
        require(users.length == amounts.length);
        uint256 loops = users.length;
        for (uint256 i = 0; i < loops; i++) {
            address user = users[i];
            uint256 amount = amounts[i];
            token.safeTransferFrom(address(this), user, amount);
            emit TokensAirdropped(user, amount);
        }
    }
}
