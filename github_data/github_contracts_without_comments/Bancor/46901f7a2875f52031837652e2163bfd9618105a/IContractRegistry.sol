
pragma solidity 0.6.12;


interface icontractregistry {
    function addressof(bytes32 _contractname) external view returns (address);
}
