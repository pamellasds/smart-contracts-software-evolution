import subprocess
import glob
import os
from fuzzywuzzy import fuzz
import git


repos = [
"https://github.com/smartcontractkit/LinkToken.git",
"https://github.com/HuobiRussia/HuobiTokenRussia.git",
"https://github.com/vechain/thor-builtins.git",
"https://github.com/paxosglobal/pax-contracts.git",
"https://github.com/trusttoken/TrustToken-smart-contracts.git",
"https://github.com/0xDd216/reputation-token.git",
"https://github.com/seita-uc/kybernetwork-sample.git",
"https://github.com/makerdao/dss.git",
"https://github.com/thetatoken/theta-erc20-token-sale.git",
"https://github.com/nexofinance/NEXO-Token.git",
"https://github.com/blockChainB/enjincoin.git",
"https://github.com/mcopteam/mcop-tokensale.git",
"https://github.com/paxosglobal/busd-contract.git",
"https://github.com/Bytom/Contracts.git",
"https://github.com/DxChainNetwork/dxchain-token-contracts.git",
"https://github.com/SwipeWallet/Swipe-Token.git",
"https://github.com/Zilliqa/Zilliqa-ERC20-Token.git",
"https://github.com/gonuco/aion.erc.contract.git",
"https://github.com/seeleteam/seeletoken.git",
"https://github.com/golemfactory/golem-crowdfunding.git",
"https://github.com/waxio/wax-erc20-delivery-contract.git",
"https://github.com/iExecBlockchainComputing/rlc-faucet-contract.git",
"https://github.com/ankurdaharwal/PowerLedger.git",
"https://github.com/decentraland/land.git",
"https://github.com/aragon/aragon-network-token.git",
"https://github.com/bancorprotocol/contracts.git",
"https://github.com/rublixdev/hedgtokenmint.git",
"https://github.com/ocg1/DAPP-1.git",
"https://github.com/Synthetixio/synthetix.git",
"https://github.com/okex/okberc20token.git"
]

tokens = [
"ChainLink-Token",
"HuobiToken",
"VeChain",
"Paxos-Standard",
"TrueUSD",
"Reputation",
"KyberNetwork",
"Dai-Stablecoin",
"Theta-Token",
"Nexo",
"EnjinCoin",
"MCO",
"Binance-USD",
"Bytom",
"DxChain-Token",
"Swipe",
"Zilliqa",
"AION",
"SeeleToken",
"Golem",
"WAX-Token",
"RLC",
"PowerLedger",
"Decentraland",
"Aragon",
"Bancor",
"HEDG",
"EthLend",
"Synthetix Network Token",
"OKB"
]

#Criação de diretórios para projetos
for token in tokens:
        path = "github_repos/"
        try:
            os.mkdir(path+token)
        except OSError:
            print ("Creation of the directory %s failed" % path)

#Clonagem de repositórios para respectivos diretórios
count = 0
for repo, token in zip(repos, tokens):
        subprocess.Popen(["git", "-C", "github_repos/"+tokens[count],"clone", repo, token], stdout=subprocess.PIPE).communicate()
        count= count+1

#Obtenção de commits para cada repositório
for token in tokens:
    g = git.Git("github_repos/"+token+"/"+token) 
    loginfo = g.log('--first-parent','--pretty="%H"')
    commits_file = open("github_commits/" + token + "_commits.txt", "w")
    for line in loginfo:
        commits_file.write(line.strip('"'))
    commits_file.close()
