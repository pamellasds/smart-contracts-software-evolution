pragma solidity 0.4.25;

import ;
import ;


contract mixinresolver is owned {
    addressresolver public resolver;

    mapping(bytes32 => address) private addresscache;

    bytes32[] public resolveraddressesrequired;

    uint public constant max_addresses_from_resolver = 24;

    constructor(address _owner, address _resolver, bytes32[24] _addressestocache) public owned(_owner) {
        for (uint i = 0; i < _addressestocache.length; i++) {
            if (_addressestocache[i] != bytes32(0)) {
                resolveraddressesrequired.push(_addressestocache[i]);
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

    

    function requireandgetaddress(bytes32 name, string reason) internal view returns (address) {
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

    
    function getresolveraddresses() external view returns (bytes32[max_addresses_from_resolver] addresses) {
        for (uint i = 0; i < resolveraddressesrequired.length; i++) {
            addresses[i] = resolveraddressesrequired[i];
        }
    }

    
    function updateaddresscache(bytes32 name) internal {
        resolveraddressesrequired.push(name);
        require(resolveraddressesrequired.length < max_addresses_from_resolver, );
        
        
        addresscache[name] = resolver.getaddress(name);
    }
}
