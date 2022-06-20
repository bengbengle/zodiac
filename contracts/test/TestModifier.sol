// SPDX-License-Identifier: LGPL-3.0-only

/// @title Modifier Interface - 位于 Module 和 Avatar 之间并执行一些额外逻辑的合约
pragma solidity >=0.7.0 <0.9.0;

import "../core/Modifier.sol";

contract TestModifier is Modifier {
    event executed(
        address to,
        uint256 value,
        bytes data,
        Enum.Operation operation,
        bool success
    );

    event executedAndReturnedData(
        address to,
        uint256 value,
        bytes data,
        Enum.Operation operation,
        bytes returnData,
        bool success
    );

    constructor(address _avatar, address _target) {
        bytes memory initParams = abi.encode(_avatar, _target);
        setUp(initParams);
    }

    /// @dev 将事务传递给修饰符 
    /// @param to 模块事务的目标地址 
    /// @param value 模块事务的以太值 
    /// @param data 模块事务的数据载荷 
    /// @param operation 模块事务的操作类型 
    /// @notice 可以仅由启用的模块调用
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    ) public override moduleOnly returns (bool success) {
        success = exec(to, value, data, operation);
        emit executed(to, value, data, operation, success);
    }
    
    /// @dev 将事务传递给修饰符，期望返回数据。 
    /// @param to 模块事务的目标地址 
    /// @param value 模块事务的以太值 
    /// @param data 模块事务的数据载荷 
    /// @param operation 模块事务的操作类型 
    /// @notice 可以仅由启用的模块调用
    function execTransactionFromModuleReturnData(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    )
        public
        override
        moduleOnly
        returns (bool success, bytes memory returnData)
    {
        (success, returnData) = execAndReturnData(to, value, data, operation);
        emit executedAndReturnedData(
            to,
            value,
            data,
            operation,
            returnData,
            success
        );
    }

    function setUp(bytes memory initializeParams) public override initializer {
        __Ownable_init();
        (address _avatar, address _target) = abi.decode(
            initializeParams,
            (address, address)
        );
        avatar = _avatar;
        target = _target;
    }
}
