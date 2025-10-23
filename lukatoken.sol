// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/IERC20.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
contract FirstToken {

    uint256 private _totalsupply; 
    mapping(address account => uint256) private balances;
    string private tokenname;
    string private tokensymbol;
    uint private _decimals = 2;
    address public owner;
    uint private price = 6;
    constructor(uint256 _supply, string memory _name, string memory _symbol) {
        owner = msg.sender;
        _totalsupply = _supply;
        balances[msg.sender] = _supply;
        tokenname = _name;
        tokensymbol = _symbol;
        //_decimals = _decimals_;
        
    }
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Mint(address indexed to, uint256 amount);

    event Sell(address indexed who, uint256 amount);

    function totalSupply() public view virtual returns (uint256){
        return _totalsupply;
    }
    function balanceOf(address account) public view virtual returns (uint256){
        return balances[account];
    }
    function getName() public view virtual returns (string memory) {
        return tokenname;
    }
    function getSymbol() public view virtual returns (string memory) {
        return tokensymbol;
    }
    function getPrice() public view virtual returns (uint256){
        return price * (10**_decimals);
    }

    function mint(address to,uint256 amount) public returns (bool){
        require(msg.sender == owner, "only owner can mint");
        _totalsupply += amount;
        balances[to] += amount;
        emit Mint(to, amount);
        return true;
    }
    function sell(uint256 value) public returns (bool){
        require(balances[msg.sender]>0,"You need tokens to sell them");
        balances[msg.sender] -= value;
        _totalsupply -= value;
        payable(msg.sender).transfer(value*price);
        emit Sell(msg.sender,value);
        return true;
    }
    function transfer(address to, uint256 value) public returns (bool){
        require(balances[msg.sender]>=value, "You do not have enough tokens");
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender,to,value);
        return true;
    }

    function close() public {
        require(msg.sender == owner, "Only owner can close the contract");
        selfdestruct(payable(owner));
    }

    fallback() external payable{ }
    receive() external payable { }


}