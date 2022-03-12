pragma solidity 0.4.26;
import ;
import ;


contract converterregistrydata is iconverterregistrydata, contractregistryclient {
    struct item {
        bool valid;
        uint256 index;
    }

    struct items {
        address[] array;
        mapping(address => item) table;
    }

    struct list {
        uint256 index;
        items items;
    }

    struct lists {
        address[] array;
        mapping(address => list) table;
    }

    items private smarttokens;
    items private liquiditypools;
    lists private convertibletokens;

    
    constructor(icontractregistry _registry) contractregistryclient(_registry) public {
    }

    
    function addsmarttoken(address _smarttoken) external only(converter_registry) {
        additem(smarttokens, _smarttoken);
    }

    
    function removesmarttoken(address _smarttoken) external only(converter_registry) {
        removeitem(smarttokens, _smarttoken);
    }

    
    function addliquiditypool(address _liquiditypool) external only(converter_registry) {
        additem(liquiditypools, _liquiditypool);
    }

    
    function removeliquiditypool(address _liquiditypool) external only(converter_registry) {
        removeitem(liquiditypools, _liquiditypool);
    }

    
    function addconvertibletoken(address _convertibletoken, address _smarttoken) external only(converter_registry) {
        list storage list = convertibletokens.table[_convertibletoken];
        if (list.items.array.length == 0) {
            list.index = convertibletokens.array.push(_convertibletoken)  1;
        }
        additem(list.items, _smarttoken);
    }

    
    function removeconvertibletoken(address _convertibletoken, address _smarttoken) external only(converter_registry) {
        list storage list = convertibletokens.table[_convertibletoken];
        removeitem(list.items, _smarttoken);
        if (list.items.array.length == 0) {
            address lastconvertibletoken = convertibletokens.array[convertibletokens.array.length  1];
            convertibletokens.table[lastconvertibletoken].index = list.index;
            convertibletokens.array[list.index] = lastconvertibletoken;
            convertibletokens.array.length;
            delete convertibletokens.table[_convertibletoken];
        }
    }

    
    function getsmarttokencount() external view returns (uint256) {
        return smarttokens.array.length;
    }

    
    function getsmarttokens() external view returns (address[]) {
        return smarttokens.array;
    }

    
    function getsmarttoken(uint256 _index) external view returns (address) {
        return smarttokens.array[_index];
    }

    
    function issmarttoken(address _value) external view returns (bool) {
        return smarttokens.table[_value].valid;
    }

    
    function getliquiditypoolcount() external view returns (uint256) {
        return liquiditypools.array.length;
    }

    
    function getliquiditypools() external view returns (address[]) {
        return liquiditypools.array;
    }

    
    function getliquiditypool(uint256 _index) external view returns (address) {
        return liquiditypools.array[_index];
    }

    
    function isliquiditypool(address _value) external view returns (bool) {
        return liquiditypools.table[_value].valid;
    }

    
    function getconvertibletokencount() external view returns (uint256) {
        return convertibletokens.array.length;
    }

    
    function getconvertibletokens() external view returns (address[]) {
        return convertibletokens.array;
    }

    
    function getconvertibletoken(uint256 _index) external view returns (address) {
        return convertibletokens.array[_index];
    }

    
    function isconvertibletoken(address _value) external view returns (bool) {
        return convertibletokens.table[_value].items.array.length > 0;
    }

    
    function getconvertibletokensmarttokencount(address _convertibletoken) external view returns (uint256) {
        return convertibletokens.table[_convertibletoken].items.array.length;
    }

    
    function getconvertibletokensmarttokens(address _convertibletoken) external view returns (address[]) {
        return convertibletokens.table[_convertibletoken].items.array;
    }

    
    function getconvertibletokensmarttoken(address _convertibletoken, uint256 _index) external view returns (address) {
        return convertibletokens.table[_convertibletoken].items.array[_index];
    }

    
    function isconvertibletokensmarttoken(address _convertibletoken, address _value) external view returns (bool) {
        return convertibletokens.table[_convertibletoken].items.table[_value].valid;
    }

    
    function additem(items storage _items, address _value) internal validaddress(_value) {
        item storage item = _items.table[_value];
        require(!item.valid, );

        item.index = _items.array.push(_value)  1;
        item.valid = true;
    }

    
    function removeitem(items storage _items, address _value) internal validaddress(_value) {
        item storage item = _items.table[_value];
        require(item.valid, );

        address lastvalue = _items.array[_items.array.length  1];
        _items.table[lastvalue].index = item.index;
        _items.array[item.index] = lastvalue;
        _items.array.length;
        delete _items.table[_value];
    }
}
