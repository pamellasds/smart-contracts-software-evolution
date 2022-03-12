
pragma solidity 0.4.25;

import ;
import ;
import ;
import ;
import ;

contract arbrewarder is selfdestructible, pausable {

    using safemath for uint;
    using safedecimalmath for uint;

    
    uint off_peg_min = 100;

    
    uint acceptable_slippage = 100;

    
    uint max_delay = 600;

    
    uint constant divisor = 10000;

    
    address public uniswapaddress = 0xe9cf7887b93150d4f2da7dfc6d502b216438f244;
    address public synthetixproxy = 0xc011a73ee8576fb46f5e1c5751ca3b9fe0af2a6f;

    iexchangerates public exchangerates = iexchangerates(0x99a46c42689720d9118ff7af7ce80c2a92fc4f97);
    iuniswapexchange public uniswapexchange = iuniswapexchange(uniswapaddress);

    ierc20 public synth = ierc20(0x5e74c9036fb86bd7ecdcb084a0673efc32ea31cb);
    ierc20 public synthetix = ierc20(synthetixproxy);

    
    

    
    constructor(address _owner)
        
        selfdestructible(_owner)
        pausable(_owner)
        public
    {}

    

    function setparams(uint _acceptable_slippage, uint _max_delay, uint _off_peg_min) external onlyowner {
        require(_off_peg_min < divisor, );
        require(_acceptable_slippage < divisor, );
        acceptable_slippage = _acceptable_slippage;
        max_delay = _max_delay;
        off_peg_min = _off_peg_min;
    }

    function setsynthetix(address _address) external onlyowner {
        synthetixproxy = _address;
        synthetix = ierc20(synthetixproxy);
    }

    function setsynthaddress(address _synthaddress) external onlyowner {
        synth = ierc20(_synthaddress);
        synth.approve(uniswapaddress, uint(1));
    }

    function setuniswapexchange(address _uniswapaddress) external onlyowner {
        uniswapaddress = _uniswapaddress;
        uniswapexchange = iuniswapexchange(uniswapaddress);
        synth.approve(uniswapaddress, uint(1));
    }

    function setexchangerates(address _exchangeratesaddress) external onlyowner {
        exchangerates = iexchangerates(_exchangeratesaddress);
    }

    

    function recovereth(address to_addr) external onlyowner {
        to_addr.transfer(address(this).balance);
    }

    function recovererc20(address erc20_addr, address to_addr) external onlyowner {
        ierc20 erc20_interface = ierc20(erc20_addr);
        erc20_interface.transfer(to_addr, erc20_interface.balanceof(address(this)));
    }

    

    
    function arbsynthrate() public payable
        ratenotstale()
        ratenotstale()
        notpaused
        returns (uint reward_tokens)
    {
        
        uint seth_in_uniswap = synth.balanceof(uniswapaddress);
        uint eth_in_uniswap = uniswapaddress.balance;
        require(eth_in_uniswap.dividedecimal(seth_in_uniswap) < uint(divisoroff_peg_min).dividedecimal(divisor), );

        
        uint max_eth_to_convert = maxconvert(eth_in_uniswap, seth_in_uniswap, divisor, divisoroff_peg_min);
        uint eth_to_convert = min(msg.value, max_eth_to_convert);
        uint unspent_input = msg.value  eth_to_convert;

        
        uint min_seth_bought = expectedoutput(uniswapexchange, eth_to_convert);
        uint tokens_bought = uniswapexchange.ethtotokenswapinput.value(eth_to_convert)(min_seth_bought, now + max_delay);

        
        reward_tokens = rewardcaller(tokens_bought, unspent_input);
    }

    function isarbable()
        public
        returns (bool)
    {
        uint seth_in_uniswap = synth.balanceof(uniswapaddress);
        uint eth_in_uniswap = uniswapaddress.balance;
        return eth_in_uniswap.dividedecimal(seth_in_uniswap) < uint(divisoroff_peg_min).dividedecimal(divisor);
    }

    

    function rewardcaller(uint bought, uint unspent_input)
        private
        returns
        (uint reward_tokens)
    {
        uint snx_rate = exchangerates.rateforcurrency();
        uint eth_rate = exchangerates.rateforcurrency();

        reward_tokens = eth_rate.multiplydecimal(bought).dividedecimal(snx_rate);
        synthetix.transfer(msg.sender, reward_tokens);

        if(unspent_input > 0) {
            msg.sender.transfer(unspent_input);
        }
    }

    function expectedoutput(iuniswapexchange exchange, uint input) private view returns (uint output) {
        output = exchange.gettokentoethinputprice(input);
        output = applyslippage(output);
    }

    function applyslippage(uint input) private view returns (uint output) {
        output = input  (input * (acceptable_slippage / divisor));
    }

    
    function maxconvert(uint a, uint b, uint n, uint d) private pure returns (uint result) {
        result = (sqrt((a * (9*a*n + 3988000*b*d)) / n)  1997*a) / 1994;
    }

    function sqrt(uint x) private pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function min(uint a, uint b) private pure returns (uint result) {
        result = a > b ? b : a;
    }

    

    modifier ratenotstale(bytes32 currencykey) {
        require(!exchangerates.rateisstale(currencykey), );
        _;
    }
}

contract iuniswapexchange {
    
    function tokenaddress() external view returns (address token);
    
    function factoryaddress() external view returns (address factory);
    
    function addliquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);
    function removeliquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
    
    function getethtotokeninputprice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getethtotokenoutputprice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function gettokentoethinputprice(uint256 tokens_sold) external view returns (uint256 eth_bought);
    function gettokentoethoutputprice(uint256 eth_bought) external view returns (uint256 tokens_sold);
    
    function ethtotokenswapinput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);
    function ethtotokentransferinput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);
    function ethtotokenswapoutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);
    function ethtotokentransferoutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);
    
    function tokentoethswapinput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);
    function tokentoethtransferinput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    function tokentoethswapoutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);
    function tokentoethtransferoutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);
    
    function tokentotokenswapinput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);
    function tokentotokentransferinput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);
    function tokentotokenswapoutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
    function tokentotokentransferoutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);
    
    function tokentoexchangeswapinput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);
    function tokentoexchangetransferinput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);
    function tokentoexchangeswapoutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);
    function tokentoexchangetransferoutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);
    
    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferfrom(address _from, address _to, uint256 value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceof(address _owner) external view returns (uint256);
    function totalsupply() external view returns (uint256);
    
    function setup(address token_addr) external;
}
