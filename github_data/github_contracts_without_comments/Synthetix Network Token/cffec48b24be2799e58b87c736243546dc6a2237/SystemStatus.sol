pragma solidity 0.4.25;

import ;


contract systemstatus is owned {
    struct status {
        bool cansuspend;
        bool canresume;
    }

    mapping(bytes32 => mapping(address => status)) public accesscontrol;

    struct suspension {
        bool suspended;
        
        
        uint248 reason;
    }

    uint248 public constant suspension_reason_upgrade = 1;

    bytes32 public constant section_system = ;
    bytes32 public constant section_issuance = ;
    bytes32 public constant section_exchange = ;
    bytes32 public constant section_synth = ;

    suspension public systemsuspension;

    suspension public issuancesuspension;

    suspension public exchangesuspension;

    mapping(bytes32 => suspension) public synthsuspension;

    constructor(address _owner) public owned(_owner) {
        _internalupdateaccesscontrol(section_system, _owner, true, true);
        _internalupdateaccesscontrol(section_issuance, _owner, true, true);
        _internalupdateaccesscontrol(section_exchange, _owner, true, true);
        _internalupdateaccesscontrol(section_synth, _owner, true, true);
    }

    
    function requiresystemactive() external view {
        _internalrequiresystemactive();
    }

    function requireissuanceactive() external view {
        
        _internalrequiresystemactive();
        require(!issuancesuspension.suspended, );
    }

    function requireexchangeactive() external view {
        
        _internalrequiresystemactive();
        require(!exchangesuspension.suspended, );
    }

    function requiresynthactive(bytes32 currencykey) external view {
        
        _internalrequiresystemactive();
        require(!synthsuspension[currencykey].suspended, );
    }

    function requiresynthsactive(bytes32 sourcecurrencykey, bytes32 destinationcurrencykey) external view {
        
        _internalrequiresystemactive();

        require(
            !synthsuspension[sourcecurrencykey].suspended && !synthsuspension[destinationcurrencykey].suspended,
            
        );
    }

    function issystemupgrading() external view returns (bool) {
        return systemsuspension.suspended && systemsuspension.reason == suspension_reason_upgrade;
    }

    function getsynthsuspensions(bytes32[] synths)
        external
        view
        returns (bool[] memory suspensions, uint256[] memory reasons)
    {
        suspensions = new bool[](synths.length);
        reasons = new uint256[](synths.length);

        for (uint i = 0; i < synths.length; i++) {
            suspensions[i] = synthsuspension[synths[i]].suspended;
            reasons[i] = synthsuspension[synths[i]].reason;
        }
    }

    
    function updateaccesscontrol(bytes32 section, address account, bool cansuspend, bool canresume) external onlyowner {
        _internalupdateaccesscontrol(section, account, cansuspend, canresume);
    }

    function suspendsystem(uint256 reason) external {
        _requireaccesstosuspend(section_system);
        systemsuspension.suspended = true;
        systemsuspension.reason = uint248(reason);
        emit systemsuspended(systemsuspension.reason);
    }

    function resumesystem() external {
        _requireaccesstoresume(section_system);
        systemsuspension.suspended = false;
        emit systemresumed(uint256(systemsuspension.reason));
        systemsuspension.reason = 0;
    }

    function suspendissuance(uint256 reason) external {
        _requireaccesstosuspend(section_issuance);
        issuancesuspension.suspended = true;
        issuancesuspension.reason = uint248(reason);
        emit issuancesuspended(reason);
    }

    function resumeissuance() external {
        _requireaccesstoresume(section_issuance);
        issuancesuspension.suspended = false;
        emit issuanceresumed(uint256(issuancesuspension.reason));
        issuancesuspension.reason = 0;
    }

    function suspendexchange(uint256 reason) external {
        _requireaccesstosuspend(section_exchange);
        exchangesuspension.suspended = true;
        exchangesuspension.reason = uint248(reason);
        emit exchangesuspended(reason);
    }

    function resumeexchange() external {
        _requireaccesstoresume(section_exchange);
        exchangesuspension.suspended = false;
        emit exchangeresumed(uint256(exchangesuspension.reason));
        exchangesuspension.reason = 0;
    }

    function suspendsynth(bytes32 currencykey, uint256 reason) external {
        _requireaccesstosuspend(section_synth);
        synthsuspension[currencykey].suspended = true;
        synthsuspension[currencykey].reason = uint248(reason);
        emit synthsuspended(currencykey, reason);
    }

    function resumesynth(bytes32 currencykey) external {
        _requireaccesstoresume(section_synth);
        emit synthresumed(currencykey, uint256(synthsuspension[currencykey].reason));
        delete synthsuspension[currencykey];
    }

    

    function _requireaccesstosuspend(bytes32 section) internal view {
        require(accesscontrol[section][msg.sender].cansuspend, );
    }

    function _requireaccesstoresume(bytes32 section) internal view {
        require(accesscontrol[section][msg.sender].canresume, );
    }

    function _internalrequiresystemactive() internal view {
        require(
            !systemsuspension.suspended,
            systemsuspension.reason == suspension_reason_upgrade
                ? 
                : 
        );
    }

    function _internalupdateaccesscontrol(bytes32 section, address account, bool cansuspend, bool canresume) internal {
        require(
            section == section_system ||
                section == section_issuance ||
                section == section_exchange ||
                section == section_synth,
            
        );
        accesscontrol[section][account].cansuspend = cansuspend;
        accesscontrol[section][account].canresume = canresume;
        emit accesscontrolupdated(section, account, cansuspend, canresume);
    }

    

    event systemsuspended(uint256 reason);
    event systemresumed(uint256 reason);

    event issuancesuspended(uint256 reason);
    event issuanceresumed(uint256 reason);

    event exchangesuspended(uint256 reason);
    event exchangeresumed(uint256 reason);

    event synthsuspended(bytes32 currencykey, uint256 reason);
    event synthresumed(bytes32 currencykey, uint256 reason);

    event accesscontrolupdated(bytes32 indexed section, address indexed account, bool cansuspend, bool canresume);
}
