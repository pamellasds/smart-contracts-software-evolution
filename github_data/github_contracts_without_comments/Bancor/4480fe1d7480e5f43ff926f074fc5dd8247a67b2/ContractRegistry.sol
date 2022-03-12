pragma solidity ^0.4.21;
import ;
import ;


contract contractregistry is icontractregistry, owned {
    mapping (bytes32 => address) addresses;

    event addressupdate(bytes32 indexed _contractname, address _contractaddress);

    
    function contractregistry() public {
    }

    
    function getaddress(bytes32 _contractname) public view returns (address) {
        return addresses[_contractname];
    }

    
    function registeraddress(bytes32 _contractname, address _contractaddress) public owneronly {
        require(_contractname.length > 0); 

        addresses[_contractname] = _contractaddress;
        emit addressupdate(_contractname, _contractaddress);
    }
}
