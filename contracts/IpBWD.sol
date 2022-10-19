// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IpBWD {
    function mint(address account_, uint256 amount_) external;

    function totalSupply() external view returns (uint256);
}
