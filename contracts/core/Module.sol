// SPDX-License-Identifier: LGPL-3.0-only

/// @title Module Interface - A contract that can pass messages to a Module Manager contract if enabled by that contract.
pragma solidity >=0.7.0 <0.9.0;

import "../interfaces/IAvatar.sol";
import "../factory/FactoryFriendly.sol";
import "../guard/Guardable.sol";

abstract contract Module is FactoryFriendly, Guardable {
    /// @dev 最终将执行函数调用的地址
    address public avatar;
    /// @dev 该模块将交易传递到的地址
    address public target;

    /// @dev 每次设置 Avatar 时发出
    event AvatarSet(address indexed previousAvatar, address indexed newAvatar);
    /// @dev 每次设置目标时发出
    event TargetSet(address indexed previousTarget, address indexed newTarget);

    /// @dev 将 Avatar 设置为新 Avatar（`newAvatar`）
    /// @notice 只能由当前所有者调用
    function setAvatar(address _avatar) public onlyOwner {
        address previousAvatar = avatar;
        avatar = _avatar;
        emit AvatarSet(previousAvatar, _avatar);
    }

    /// @dev 将目标设置为新目标 (`newTarget`)
    /// @notice 只能由当前所有者调用
    function setTarget(address _target) public onlyOwner {
        address previousTarget = target;
        target = _target;
        emit TargetSet(previousTarget, _target);
    }

   
    /// @dev 传递要由 Avatar 执行的事务 
    /// @notice 只能被这个合约调用
    /// @param to 模块事务的目标地址 
    /// @param value 模块交易的以太币值 
    /// @param data 模块事务的数据负载 
    /// @param operation 模块事务的操作类型：0 == 调用，1 == 委托调用。
    function exec(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) internal returns (bool success) {
        /// 检查是否启用了事务保护
        if (guard != address(0)) {
            IGuard(guard).checkTransaction(
                /// 模块事务使用的事务信息
                to,
                value,
                data,
                operation,
                /// 将仅用于安全多重签名交易的冗余交易信息清零
                0,
                0,
                0,
                address(0),
                payable(0),
                bytes("0x"),
                msg.sender
            );
        }
        success = IAvatar(target).execTransactionFromModule(
            to,
            value,
            data,
            operation
        );
        if (guard != address(0)) {
            IGuard(guard).checkAfterExecution(bytes32("0x"), success);
        }
        return success;
    }
    
    /// @dev 传递要由目标执行的事务并返回数据。 
    /// @notice 只能被这个合约调用。 
    /// @param to 模块事务的目标地址。 
    /// @param value 模块交易的以太币值。 
    /// @param data 模块事务的数据负载。 
    /// @param operation 模块事务的操作类型：0 == 调用，1 == 委托调用。
    function execAndReturnData(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) internal returns (bool success, bytes memory returnData) {
        /// 检查是否启用了事务保护。
        if (guard != address(0)) {
            IGuard(guard).checkTransaction(
                /// 模块事务使用的事务信息
                to,
                value,
                data,
                operation,
                /// 将仅用于安全多重签名交易的冗余交易信息清零
                0,
                0,
                0,
                address(0),
                payable(0),
                bytes("0x"),
                msg.sender
            );
        }
        (success, returnData) = IAvatar(target).execTransactionFromModuleReturnData(to, value, data, operation);
        
        if (guard != address(0)) {
            IGuard(guard).checkAfterExecution(bytes32("0x"), success);
        }
        return (success, returnData);
    }
}
