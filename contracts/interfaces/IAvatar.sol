// SPDX-License-Identifier: LGPL-3.0-only

/// @title Zodiac Avatar - 管理可以通过该合约执行交易的模块的合约
pragma solidity >=0.7.0 <0.9.0;

import "@gnosis.pm/safe-contracts/contracts/common/Enum.sol";

interface IAvatar {
    /// @dev 在头像上启用一个模块 
    /// @notice 只能被头像调用
    /// @notice 模块应该存储为链表
    /// @notice 如果成功，必须发出 EnabledModule(address module) 
    /// @param module 要启用的模块
    function enableModule(address module) external;

    /// @dev 禁用头像上的模块 
    /// @notice 只能被头像调用
    /// @notice 如果成功，必须发出 DisabledModule(address module) 
    /// @param prevModule 指向链表中要移除的模块的地址 
    /// @param module 要移除的模块
    function disableModule(address prevModule, address module) external;

    /// @dev 允许模块执行事务
    /// @notice 只能由启用的模块调用
    /// @notice 如果成功，必须发出 ExecutionFromModuleSuccess(address module) 
    /// @notice 如果不成功，必须发出 ExecutionFromModuleFailure(address module) 
    /// @param to 模块事务的目标地址
    /// @param value 模块交易的以太币值 
    /// @param data 模块事务的数据负载
    /// @param operation 模块事务的操作类型：0 == 调用，1 == 委托调用
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) external returns (bool success);
    
    /// @dev 允许模块执行事务并返回数据 
    /// @notice 只能由启用的模块调用
    /// @notice 如果成功，必须发出 ExecutionFromModuleSuccess(address module) 
    /// @notice 如果不成功，必须发出 ExecutionFromModuleFailure(address module) 
    /// @param to 模块事务的目标地址 
    /// @param value 模块交易的以太币值 
    /// @param data 模块事务的数据负载 
    /// @param operation 模块事务的操作类型：0 == 调用，1 == 委托调用
    function execTransactionFromModuleReturnData(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) external returns (bool success, bytes memory returnData);

    /// @dev 如果启用了模块，则返回 
    /// @return 如果启用了模块，则返回 True
    function isModuleEnabled(address module) external view returns (bool);

    /// @dev 返回模块数组
    /// @param start 页面的开始
    /// @param pageSize 应该返回的最大模块数 
    /// @return array 模块数组
    /// @return next 下一页的开始
    function getModulesPaginated(address start, uint256 pageSize)
        external
        view
        returns (address[] memory array, address next);
}
