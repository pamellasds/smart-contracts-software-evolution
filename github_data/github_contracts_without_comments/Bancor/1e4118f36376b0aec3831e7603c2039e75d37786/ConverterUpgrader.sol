pragma solidity 0.4.26;
import ;
import ;
import ;
import ;
import ;
import ;


contract converterupgrader is iconverterupgrader, contractregistryclient {
    address private constant eth_reserve_address = 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee;
    iethertoken public ethertoken;

    
    event converterowned(address indexed _converter, address indexed _owner);

    
    event converterupgrade(address indexed _oldconverter, address indexed _newconverter);

    
    constructor(icontractregistry _registry, iethertoken _ethertoken) contractregistryclient(_registry) public {
        ethertoken = _ethertoken;
    }

    
    function upgrade(bytes32 _version) public {
        upgradeold(iconverter(msg.sender), _version);
    }

    
    function upgrade(uint16 _version) public {
        upgradeold(iconverter(msg.sender), bytes32(_version));
    }

    
    function upgradeold(iconverter _converter, bytes32 _version) public {
        _version;
        iconverter converter = iconverter(_converter);
        address prevowner = converter.owner();
        acceptconverterownership(converter);
        iconverter newconverter = createconverter(converter);
        copyreserves(converter, newconverter);
        copyconversionfee(converter, newconverter);
        transferreservebalances(converter, newconverter);
        iconverteranchor anchor = converter.token();

        if (anchor.owner() == address(converter)) {
            converter.transfertokenownership(newconverter);
            newconverter.acceptanchorownership();
        }

        converter.transferownership(prevowner);
        newconverter.transferownership(prevowner);

        emit converterupgrade(address(converter), address(newconverter));
    }

    
    function acceptconverterownership(iconverter _oldconverter) private {
        _oldconverter.acceptownership();
        emit converterowned(_oldconverter, this);
    }

    
    function createconverter(iconverter _oldconverter) private returns (iconverter) {
        iconverteranchor anchor = _oldconverter.token();
        uint32 maxconversionfee = _oldconverter.maxconversionfee();
        uint16 reservetokencount = _oldconverter.connectortokencount();

        
        uint16 newtype = 0;
        
        if (isv28orhigherconverter(_oldconverter))
            newtype = _oldconverter.convertertype();
        
        else if (reservetokencount > 1)
            newtype = 1;

        iconverterfactory converterfactory = iconverterfactory(addressof(converter_factory));
        iconverter converter = converterfactory.createconverter(newtype, anchor, registry, maxconversionfee);

        converter.acceptownership();
        return converter;
    }

    
    function copyreserves(iconverter _oldconverter, iconverter _newconverter)
        private
    {
        uint16 reservetokencount = _oldconverter.connectortokencount();

        for (uint16 i = 0; i < reservetokencount; i++) {
            address reserveaddress = _oldconverter.connectortokens(i);
            (, uint32 weight, , , ) = _oldconverter.connectors(reserveaddress);

            
            if (reserveaddress == eth_reserve_address) {
                _newconverter.addreserve(ierc20token(eth_reserve_address), weight);
            }
            
            else if (reserveaddress == address(ethertoken)) {
                _newconverter.addreserve(ierc20token(eth_reserve_address), weight);
            }
            
            else {
                _newconverter.addreserve(ierc20token(reserveaddress), weight);
            }
        }
    }

    
    function copyconversionfee(iconverter _oldconverter, iconverter _newconverter) private {
        uint32 conversionfee = _oldconverter.conversionfee();
        _newconverter.setconversionfee(conversionfee);
    }

    
    function transferreservebalances(iconverter _oldconverter, iconverter _newconverter)
        private
    {
        uint256 reservebalance;
        uint16 reservetokencount = _oldconverter.connectortokencount();

        for (uint16 i = 0; i < reservetokencount; i++) {
            address reserveaddress = _oldconverter.connectortokens(i);
            
            if (reserveaddress == eth_reserve_address) {
                _oldconverter.withdraweth(address(_newconverter));
            }
            
            else if (reserveaddress == address(ethertoken)) {
                reservebalance = ethertoken.balanceof(_oldconverter);
                _oldconverter.withdrawtokens(ethertoken, address(this), reservebalance);
                ethertoken.withdrawto(address(_newconverter), reservebalance);
            }
            
            else {
                ierc20token connector = ierc20token(reserveaddress);
                reservebalance = connector.balanceof(_oldconverter);
                _oldconverter.withdrawtokens(connector, address(_newconverter), reservebalance);
            }
        }
    }

    bytes4 private constant is_v28_or_higher_func_selector = bytes4(keccak256());

    
    
    function isv28orhigherconverter(iconverter _converter) internal view returns (bool) {
        bool success;
        uint256[1] memory ret;
        bytes memory data = abi.encodewithselector(is_v28_or_higher_func_selector);

        assembly {
            success := staticcall(
                gas,           
                _converter,    
                add(data, 32), 
                mload(data),   
                ret,           
                32             
            )
        }

        return success;
    }
}
