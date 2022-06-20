// SPDX-License-Identifier: LGPL-3.0-only

/// @title 修改器接口 - 位于模块和 Avatar 之间并强制执行一些额外逻辑的合约
pragma solidity >=0.7.0 <0.9.0;

import "../interfaces/IAvatar.sol";
import "./Module.sol";

abstract contract Modifier is Module, IAvatar {
    address internal constant SENTINEL_MODULES = address(0x1);
    /// Mapping of modules.
    mapping(address => address) internal modules;

    event EnabledModule(address module);
    event DisabledModule(address module);

    /// `sender` 不是授权模块
    /// @param sender 发件人的地址
    error NotAuthorized(address sender);

    /// `module` 无效
    error InvalidModule(address module);

    /// `module` 已经被禁用
    error AlreadyDisabledModule(address module);

    /// `module` 已经启用
    error AlreadyEnabledModule(address module);

    /*
    --------------------------------------------------
    您必须至少覆盖以下两个虚拟函数之一， execTransactionFromModule() 和 execTransactionFromModuleReturnData()
    */

   /// @notice 将事务传递给修饰符 只能由启用的模块调用 
   /// @param to 模块事务的目标地址 
   /// @param value 模块交易的以太币值 
   /// @param data 模块事务的数据负载 
   /// @param operation 模块事务的操作类型

    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    ) public virtual override moduleOnly returns (bool success) {}
    
    /// @dev 将事务传递给修饰符，期望返回数据 
    /// @notice 只能由启用的模块调用 
    /// @param to 模块事务的目标地址 
    /// @param value 模块交易的以太币值
    /// @param data 模块事务的数据负载 
    /// @param operation 模块事务的操作类型
    function execTransactionFromModuleReturnData(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    )
        public
        virtual
        override
        moduleOnly
        returns (bool success, bytes memory returnData)
    {}

    /*
    --------------------------------------------------
    */

    modifier moduleOnly() {
        if (modules[msg.sender] == address(0)) revert NotAuthorized(msg.sender);
        _;
    }
    
    /// @dev 禁用修饰符上的模块
    /// @notice 这只能由所有者调用 
    /// @param prevModule 指向链表中要移除的模块的模块 
    /// @param module 要删除的模块
    function disableModule(address prevModule, address module)
        public
        override
        onlyOwner
    {
        if (module == address(0) || module == SENTINEL_MODULES)
            revert InvalidModule(module);
        if (modules[prevModule] != module) revert AlreadyDisabledModule(module);
        modules[prevModule] = modules[module];
        modules[module] = address(0);
        emit DisabledModule(module);
    }

    /// @dev 启用可以将事务添加到队列的模块 
    /// @param module 要启用的模块的地址 
    /// @notice 这只能由所有者调用
    function enableModule(address module) public override onlyOwner {
        if (module == address(0) || module == SENTINEL_MODULES)
            revert InvalidModule(module);
        if (modules[module] != address(0)) revert AlreadyEnabledModule(module);
        modules[module] = modules[SENTINEL_MODULES];
        modules[SENTINEL_MODULES] = module;
        emit EnabledModule(module);
    }

    /// @dev 如果启用了模块，则返回 
    /// @return 如果启用了模块，则返回 True
    function isModuleEnabled(address _module)
        public
        view
        override
        returns (bool)
    {
        return SENTINEL_MODULES != _module && modules[_module] != address(0);
    }

    /// @dev 返回模块数组 
    /// @param start 页面的开始 
    /// @param pageSize 应该返回的最大模块数 
    /// @return array 模块数组 
    /// @return next 下一页的开始
    function getModulesPaginated(address start, uint256 pageSize)
        external
        view
        override
        returns (address[] memory array, address next)
    {
        /// 使用有 max page size 初始化数组
        array = new address[](pageSize);

        /// 填充返回数组
        uint256 moduleCount = 0;
        address currentModule = modules[start];
        while (
            currentModule != address(0x0) &&
            currentModule != SENTINEL_MODULES &&
            moduleCount < pageSize
        ) {
            array[moduleCount] = currentModule;
            currentModule = modules[currentModule];
            moduleCount++;
        }
        next = currentModule;
        /// @notice 设置返回数组的正确大小 
        // solhint-disable-next-line no-inline-assembly
        assembly {
            mstore(array, moduleCount)
        }
    }
}
