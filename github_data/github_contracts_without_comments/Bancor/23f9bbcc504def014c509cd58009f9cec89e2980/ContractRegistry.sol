pragma solidity ^0.4.23;
import ;
import ;
import ;


contract contractregistry is icontractregistry, owned, utils {
    struct registryitem {
        address contractaddress;    
        uint256 nameindex;          
        bool isset;                 
    }

    mapping (bytes32 => registryitem) private items;    
    string[] public contractnames;                      

    
    event addressupdate(bytes32 indexed _contractname, address _contractaddress);

    
    constructor() public {
    }

    
    function itemcount() public view returns (uint256) {
        return contractnames.length;
    }

    
    function addressof(bytes32 _contractname) public view returns (address) {
        return items[_contractname].contractaddress;
    }

    
    function registeraddress(bytes32 _contractname, address _contractaddress)
        public
        owneronly
        validaddress(_contractaddress)
    {
        require(_contractname.length > 0); 

        
        items[_contractname].contractaddress = _contractaddress;
        
        if (!items[_contractname].isset) {
            
            items[_contractname].isset = true;
            
            uint256 i = contractnames.push(bytes32tostring(_contractname));
            
            items[_contractname].nameindex = i  1;
        }

        
        emit addressupdate(_contractname, _contractaddress);
    }

    
    function unregisteraddress(bytes32 _contractname) public owneronly {
        require(_contractname.length > 0); 

        
        items[_contractname].contractaddress = address(0);

        if (items[_contractname].isset) {
            
            items[_contractname].isset = false;

            
            if (contractnames.length > 1)
                contractnames[items[_contractname].nameindex] = contractnames[contractnames.length  1];

            
            contractnames.length;
            
            items[_contractname].nameindex = 0;
        }

        
        emit addressupdate(_contractname, address(0));
    }

    
    function bytes32tostring(bytes32 _bytes) private pure returns (string) {
        bytes memory bytearray = new bytes(32);
        for (uint256 i; i < 32; i++) {
            bytearray[i] = _bytes[i];
        }

        return string(bytearray);
    }

    
    function getaddress(bytes32 _contractname) public view returns (address) {
        return addressof(_contractname);
    }
}
