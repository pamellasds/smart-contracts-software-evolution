pragma solidity 0.4.26;
import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;


contract converterbase is iconverter, tokenhandler, tokenholder, contractregistryclient, reentrancyguard {
    using safemath for uint256;

    uint32 internal constant weight_resolution = 1000000;
    uint32 internal constant conversion_fee_resolution = 1000000;
    address internal constant eth_reserve_address = 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee;

    struct reserve {
        uint256 balance;    
        uint32 weight;      
        bool deprecated1;   
        bool deprecated2;   
        bool isset;         
    }

    
    uint16 public constant version = 32;

    iconverteranchor public anchor;                 
    iwhitelist public conversionwhitelist;          
    ierc20token[] public reservetokens;             
    mapping (address => reserve) public reserves;   
    uint32 public reserveratio = 0;                 
    uint32 public maxconversionfee = 0;             
                                                    
    uint32 public conversionfee = 0;                
    bool public constant conversionsenabled = true; 

    
    event activation(uint16 indexed _type, iconverteranchor indexed _anchor, bool indexed _activated);

    
    event conversion(
        address indexed _fromtoken,
        address indexed _totoken,
        address indexed _trader,
        uint256 _amount,
        uint256 _return,
        int256 _conversionfee
    );

    
    event tokenrateupdate(
        address indexed _token1,
        address indexed _token2,
        uint256 _raten,
        uint256 _rated
    );

    
    event conversionfeeupdate(uint32 _prevfee, uint32 _newfee);

    
    constructor(
        iconverteranchor _anchor,
        icontractregistry _registry,
        uint32 _maxconversionfee
    )
        validaddress(_anchor)
        contractregistryclient(_registry)
        internal
        validconversionfee(_maxconversionfee)
    {
        anchor = _anchor;
        maxconversionfee = _maxconversionfee;
    }

    
    modifier active() {
        _active();
        _;
    }

    
    function _active() internal view {
        require(isactive(), );
    }

    
    modifier inactive() {
        _inactive();
        _;
    }

    
    function _inactive() internal view {
        require(!isactive(), );
    }

    
    modifier validreserve(ierc20token _address) {
        _validreserve(_address);
        _;
    }

    
    function _validreserve(ierc20token _address) internal view {
        require(reserves[_address].isset, );
    }

    
    modifier validconversionfee(uint32 _conversionfee) {
        _validconversionfee(_conversionfee);
        _;
    }

    
    function _validconversionfee(uint32 _conversionfee) internal pure {
        require(_conversionfee <= conversion_fee_resolution, );
    }

    
    modifier validreserveweight(uint32 _weight) {
        _validreserveweight(_weight);
        _;
    }

    
    function _validreserveweight(uint32 _weight) internal pure {
        require(_weight > 0 && _weight <= weight_resolution, );
    }

    
    function() external payable {
        require(reserves[eth_reserve_address].isset, ); 
        
        
    }

    
    function withdraweth(address _to)
        public
        protected
        owneronly
        validreserve(ierc20token(eth_reserve_address))
    {
        address converterupgrader = addressof(converter_upgrader);

        
        require(!isactive() || owner == converterupgrader, );
        _to.transfer(address(this).balance);

        
        syncreservebalance(ierc20token(eth_reserve_address));
    }

    
    function isv28orhigher() public pure returns (bool) {
        return true;
    }

    
    function setconversionwhitelist(iwhitelist _whitelist)
        public
        owneronly
        notthis(_whitelist)
    {
        conversionwhitelist = _whitelist;
    }

    
    function isactive() public view returns (bool) {
        return anchor.owner() == address(this);
    }

    
    function transferanchorownership(address _newowner)
        public
        owneronly
        only(converter_upgrader)
    {
        anchor.transferownership(_newowner);
    }

    
    function acceptanchorownership() public owneronly {
        
        require(reservetokencount() > 0, );
        anchor.acceptownership();
        syncreservebalances();
    }

    
    function withdrawfromanchor(ierc20token _token, address _to, uint256 _amount) public owneronly {
        anchor.withdrawtokens(_token, _to, _amount);
    }

    
    function setconversionfee(uint32 _conversionfee) public owneronly {
        require(_conversionfee <= maxconversionfee, );
        emit conversionfeeupdate(conversionfee, _conversionfee);
        conversionfee = _conversionfee;
    }

    
    function withdrawtokens(ierc20token _token, address _to, uint256 _amount) public protected owneronly {
        address converterupgrader = addressof(converter_upgrader);

        
        
        require(!reserves[_token].isset || !isactive() || owner == converterupgrader, );
        super.withdrawtokens(_token, _to, _amount);

        
        if (reserves[_token].isset)
            syncreservebalance(_token);
    }

    
    function upgrade() public owneronly {
        iconverterupgrader converterupgrader = iconverterupgrader(addressof(converter_upgrader));

        
        emit activation(convertertype(), anchor, false);

        transferownership(converterupgrader);
        converterupgrader.upgrade(version);
        acceptownership();
    }

    
    function reservetokencount() public view returns (uint16) {
        return uint16(reservetokens.length);
    }

    
    function addreserve(ierc20token _token, uint32 _weight)
        public
        owneronly
        inactive
        validaddress(_token)
        notthis(_token)
        validreserveweight(_weight)
    {
        
        require(_token != address(anchor) && !reserves[_token].isset, );
        require(_weight <= weight_resolution  reserveratio, );
        require(reservetokencount() < uint16(1), );

        reserve storage newreserve = reserves[_token];
        newreserve.balance = 0;
        newreserve.weight = _weight;
        newreserve.isset = true;
        reservetokens.push(_token);
        reserveratio += _weight;
    }

    
    function reserveweight(ierc20token _reservetoken)
        public
        view
        validreserve(_reservetoken)
        returns (uint32)
    {
        return reserves[_reservetoken].weight;
    }

    
    function reservebalance(ierc20token _reservetoken)
        public
        view
        validreserve(_reservetoken)
        returns (uint256)
    {
        return reserves[_reservetoken].balance;
    }

    
    function hasethreserve() public view returns (bool) {
        return reserves[eth_reserve_address].isset;
    }

    
    function convert(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount, address _trader, address _beneficiary)
        public
        payable
        protected
        only(bancor_network)
        returns (uint256)
    {
        
        require(_sourcetoken != _targettoken, );

        
        require(conversionwhitelist == address(0) ||
                (conversionwhitelist.iswhitelisted(_trader) && conversionwhitelist.iswhitelisted(_beneficiary)),
                );

        return doconvert(_sourcetoken, _targettoken, _amount, _trader, _beneficiary);
    }

    
    function doconvert(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount, address _trader, address _beneficiary) internal returns (uint256);

    
    function calculatefee(uint256 _targetamount) internal view returns (uint256) {
        return _targetamount.mul(conversionfee).div(conversion_fee_resolution);
    }

    
    function syncreservebalance(ierc20token _reservetoken) internal validreserve(_reservetoken) {
        if (_reservetoken == eth_reserve_address)
            reserves[_reservetoken].balance = address(this).balance;
        else
            reserves[_reservetoken].balance = _reservetoken.balanceof(this);
    }

    
    function syncreservebalances() internal {
        uint256 reservecount = reservetokens.length;
        for (uint256 i = 0; i < reservecount; i++)
            syncreservebalance(reservetokens[i]);
    }

    
    function dispatchconversionevent(
        ierc20token _sourcetoken,
        ierc20token _targettoken,
        address _trader,
        uint256 _amount,
        uint256 _returnamount,
        uint256 _feeamount)
        internal
    {
        
        
        
        
        assert(_feeamount < 2 ** 255);
        emit conversion(_sourcetoken, _targettoken, _trader, _amount, _returnamount, int256(_feeamount));
    }

    
    function token() public view returns (iconverteranchor) {
        return anchor;
    }

    
    function transfertokenownership(address _newowner) public owneronly {
        transferanchorownership(_newowner);
    }

    
    function accepttokenownership() public owneronly {
        acceptanchorownership();
    }

    
    function connectors(address _address) public view returns (uint256, uint32, bool, bool, bool) {
        reserve memory reserve = reserves[_address];
        return(reserve.balance, reserve.weight, false, false, reserve.isset);
    }

    
    function connectortokens(uint256 _index) public view returns (ierc20token) {
        return converterbase.reservetokens[_index];
    }

    
    function connectortokencount() public view returns (uint16) {
        return reservetokencount();
    }

    
    function getconnectorbalance(ierc20token _connectortoken) public view returns (uint256) {
        return reservebalance(_connectortoken);
    }

    
    function getreturn(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount) public view returns (uint256, uint256) {
        return targetamountandfee(_sourcetoken, _targettoken, _amount);
    }
}
