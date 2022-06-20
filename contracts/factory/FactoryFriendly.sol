// SPDX-License-Identifier: LGPL-3.0-only

/// @title Zodiac FactoryFriendly - 允许其他合约可初始化并将字节作为 参数 传递以定义合约状态的合约
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract FactoryFriendly is OwnableUpgradeable {
    function setUp(bytes memory initializeParams) public virtual;
}
