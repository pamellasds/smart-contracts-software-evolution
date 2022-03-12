pragma solidity 0.4.21;







contract abstracttoken {
	function balanceof(address owner) public view returns (uint256 balance);
	function transfer(address to, uint256 value) public returns (bool success);
	function transferfrom(address from, address to, uint256 value) public returns (bool success);
	function approve(address spender, uint256 value) public returns (bool success);
	function allowance(address owner, address spender) public view returns (uint256 remaining);

	event transfer(address indexed from, address indexed to, uint256 value);
	event approval(address indexed owner, address indexed spender, uint256 value);
}
