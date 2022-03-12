pragma solidity 0.4.26;
import ;
import ;
import ;


contract contractregistryclient is owned, utils {
    bytes32 internal constant contract_features = ;
    bytes32 internal constant contract_registry = ;
    bytes32 internal constant bancor_network = ;
    bytes32 internal constant bancor_formula = ;
    bytes32 internal constant bancor_converter_factory = ;
    bytes32 internal constant bancor_converter_upgrader = ;
    bytes32 internal constant bancor_converter_registry = ;
    bytes32 internal constant bancor_converter_registry_data = ;
    bytes32 internal constant bnt_token = ;
    bytes32 internal constant bancor_x = ;
    bytes32 internal constant bancor_x_upgrader = ;

    icontractregistry public registry;      
    icontractregistry public prevregistry;  
    bool public onlyownercanupdateregistry; 

    
    modifier only(bytes32 _contractname) {
        require(msg.sender == addressof(_contractname));
        _;
    }

    
    constructor(icontractregistry _registry) internal validaddress(_registry) {
        registry = icontractregistry(_registry);
        prevregistry = icontractregistry(_registry);
    }

    
    function updateregistry() public {
        
        require(msg.sender == owner || !onlyownercanupdateregistry);

        
        address newregistry = addressof(contract_registry);

        
        require(newregistry != address(registry) && newregistry != address(0));

        
        require(icontractregistry(newregistry).addressof(contract_registry) != address(0));

        
        prevregistry = registry;

        
        registry = icontractregistry(newregistry);
    }

    
    function restoreregistry() public owneronly {
        
        registry = prevregistry;
    }

    
    function restrictregistryupdate(bool _onlyownercanupdateregistry) owneronly public {
        
        onlyownercanupdateregistry = _onlyownercanupdateregistry;
    }

    
    function addressof(bytes32 _contractname) internal view returns (address) {
        return registry.addressof(_contractname);
    }
}
