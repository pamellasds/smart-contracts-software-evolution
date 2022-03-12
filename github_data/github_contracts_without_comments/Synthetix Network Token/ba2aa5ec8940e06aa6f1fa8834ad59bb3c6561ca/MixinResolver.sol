pragma solidity ^0.5.16;


import ;


import ;



contract mixinresolver is owned {
    addressresolver public resolver;

    mapping(bytes32 => address) private addresscache;

    bytes32[] public resolveraddressesrequired;

    uint public constant max_addresses_from_resolver = 24;

    constructor(address _resolver, bytes32[max_addresses_from_resolver] memory _addressestocache) internal {
        
        require(owner != address(0), );

        for (uint i = 0; i < _addressestocache.length; i++) {
            if (_addressestocache[i] != bytes32(0)) {
                resolveraddressesrequired.push(_addressestocache[i]);
            } else {
                
                
                break;
            }
        }
        resolver = addressresolver(_resolver);
        
    }

    
    function setresolverandsynccache(addressresolver _resolver) external onlyowner {
        resolver = _resolver;

        for (uint i = 0; i < resolveraddressesrequired.length; i++) {
            bytes32 name = resolveraddressesrequired[i];
            
            addresscache[name] = resolver.requireandgetaddress(name, );
        }
    }

    

    function requireandgetaddress(bytes32 name, string memory reason) internal view returns (address) {
        address _foundaddress = addresscache[name];
        require(_foundaddress != address(0), reason);
        return _foundaddress;
    }

    
    
    function isresolvercached(addressresolver _resolver) external view returns (bool) {
        if (resolver != _resolver) {
            return false;
        }

        
        for (uint i = 0; i < resolveraddressesrequired.length; i++) {
            bytes32 name = resolveraddressesrequired[i];
            
            if (resolver.getaddress(name) != addresscache[name] || addresscache[name] == address(0)) {
                return false;
            }
        }

        return true;
    }

    
    function getresolveraddressesrequired()
        external
        view
        returns (bytes32[max_addresses_from_resolver] memory addressesrequired)
    {
        for (uint i = 0; i < resolveraddressesrequired.length; i++) {
            addressesrequired[i] = resolveraddressesrequired[i];
        }
    }

    
    function appendtoaddresscache(bytes32 name) internal {
        resolveraddressesrequired.push(name);
        require(resolveraddressesrequired.length < max_addresses_from_resolver, );
        
        
        addresscache[name] = resolver.getaddress(name);
    }
}
