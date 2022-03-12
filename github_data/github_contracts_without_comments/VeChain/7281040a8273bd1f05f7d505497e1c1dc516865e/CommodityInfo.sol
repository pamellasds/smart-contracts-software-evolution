pragma solidity ^0.4.23;

import ;





contract commodityinfo {

    struct item {
        
        bytes id;

        
        string originplace;

        
        uint productiondate;

        
        uint shelflife;
    }

    mapping(bytes32=>item) commodity;

    using builtin for commodityinfo;

    extension extension = builtin.getextension();

    event addcommodity(bytes id, string originplace, uint productiondate, uint shelflife);

    modifier onlymasterorusers() {
        require(msg.sender == this.$master() || this.$isuser(msg.sender));
        _;
    }

    modifier onlymaster() {
        require(msg.sender == this.$master());
        _;
    }

    
    function adduser(address user) public onlymaster {
        this.$adduser(user);
    }

    function removeuser(address user) public onlymaster {
        this.$removeuser(user);
    }

    function setmaster(address master) public onlymaster {
        this.$setmaster(master);
    }

    function setcreditplan(uint256 credit, uint256 recoveryrate) public onlymaster {
        this.$setcreditplan(credit, recoveryrate);
    }

    function creditplan() public view returns(uint256 credit, uint256 recoveryrate) {
        return this.$creditplan();
    }

    
    function issponsor(address _sponsor) public view returns(bool) {
        return this.$issponsor(_sponsor);
    }

    
    function addcommodityitem(bytes id, string originplace, uint productiondate, uint shelflife) public onlymasterorusers {
        bytes32 key = extension.blake2b256(id);
        commodity[key].id = id;
        commodity[key].originplace = originplace;
        commodity[key].productiondate = productiondate;
        commodity[key].shelflife = shelflife;

        emit addcommodity(id, originplace, productiondate, shelflife);
    }

    
    function getcommodityitem(bytes id) public view returns(string, uint, uint) {
        bytes32 key = extension.blake2b256(id);
        return(commodity[key].originplace, commodity[key].productiondate, commodity[key].shelflife);
    }

    
    function iscommodityexpired(bytes id) public view returns(bool) {
        bytes32 key = extension.blake2b256(id);
        return commodity[key].productiondate + commodity[key].shelflife >= now;
    }
}
