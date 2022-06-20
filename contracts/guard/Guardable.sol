// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "@gnosis.pm/safe-contracts/contracts/common/Enum.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./BaseGuard.sol";

/// @title Guardable - 管理对此合约的回退调用的合约
contract Guardable is OwnableUpgradeable {
    address public guard;

    event ChangedGuard(address guard);

    /// `guard_` 没有实现 IERC165
    error NotIERC165Compliant(address guard_);

    /// @dev 设置一个守卫， 在执行前检查交易
    /// @param _guard 要使用的保护的地址或禁用保护的 0 地址
    function setGuard(address _guard) external onlyOwner {
        if (_guard != address(0)) {
            if (!BaseGuard(_guard).supportsInterface(type(IGuard).interfaceId))
                revert NotIERC165Compliant(_guard);
        }
        guard = _guard;
        emit ChangedGuard(guard);
    }

    function getGuard() external view returns (address _guard) {
        return guard;
    }
}
