import subprocess
import glob
import os
from fuzzywuzzy import fuzz
import git
import requests
import json
import pandas as pd


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

repos = [
"/smartcontractkit/LinkToken",
"/HuobiRussia/HuobiTokenRussia",
"/vechain/thor-builtins",
"/paxosglobal/pax-contracts",
"/trusttoken/TrustToken-smart-contracts",
"/0xDd216/reputation-token",
"/seita-uc/kybernetwork-sample",
"/makerdao/dss",
"/thetatoken/theta-erc20-token-sale",
"/nexofinance/NEXO-Token",
"/blockChainB/enjincoin",
"/mcopteam/mcop-tokensale",
"/paxosglobal/busd-contract",
"/Bytom/Contracts",
"/DxChainNetwork/dxchain-token-contracts",
"/SwipeWallet/Swipe-Token",
"/Zilliqa/Zilliqa-ERC20-Token",
"/gonuco/aion.erc.contract",
"/seeleteam/seeletoken",
"/golemfactory/golem-crowdfunding",
"/waxio/wax-erc20-delivery-contract",
"/iExecBlockchainComputing/rlc-faucet-contract",
"/ankurdaharwal/PowerLedger",
"/decentraland/land",
"/aragon/aragon-network-token",
"/bancorprotocol/contracts",
"/rublixdev/hedgtokenmint",
"/ocg1/DAPP-1",
"/Synthetixio/synthetix",
"/okex/okberc20token"
]


#Função para obter a lista de contribuidores de cada repositório e quantidade de commits de cada contribuidor
def get_contributors_insights(contributors, token):
    # data = subprocess.Popen(["git", "-C", "github_repos/" + token + "/" + token, "shortlog",  "-s", "-n"], stdout=subprocess.PIPE, universal_newlines=True).communicate()
    data = subprocess.Popen(["git", "-C", "github_repos/" + token + "/" + token, "shortlog",  "-s", "-n"], stdout=subprocess.PIPE)
    for line in data.stdout:
        contributors.write(','+line.decode().replace('\t', ', '))

#Função para obter a quantidade total de contribuidores
def get_contributors_amount(repo):
    url='https://api.github.com/repos'
    print(url + repo + "/collaborators")
    response = requests.get(url + repo + "/issues?state=all&direction=asc").json()
    
    data = []
    for x in response:
        data.append(str(x["user"]["login"]))
    
    count = 0
    contributors = []
    for line in data:
        if line in contributors:
            continue
        else:
            contributors.append(line)
            count = count + 1
    
    return count 

#Função para obter a quantidade total de commits
def get_commits_insights(token):  
    data = subprocess.Popen(["git", "-C", "github_repos/" + token + "/" + token, "rev-list",  "--all", "--count"], stdout=subprocess.PIPE, universal_newlines=True).communicate()
    return data[0]

#Função para obter insights sobre issues
def get_issues_insights(repo, insights):
    url='https://api.github.com/repos'
    print(url + repo + "/issues?state=all")
    response = requests.get(url + repo + "/issues?state=all&direction=asc").json()
    
    for x in response:
        insights.write(','+str(x['number']) + ',' + str(x['title']) + ',' + str(x["user"]["login"]) + ',' +
        str(x['state']) + ',' + str(x['created_at']) + ',' + str(x['updated_at']) + ',' +
        str(x['closed_at'])+'\n')

#Função para obter timestamp do repositório
def get_timestamp(token, project_timestamp):
    
    commits = open("github_commits/" + token  + "_commits.txt")
    for commit in commits:
        commit = commit.replace("\n","")
        data = str(subprocess.Popen(["git", "-C", "github_repos/" + token + "/" + token, "show",  "-s", "--format=" + "%ci" , commit], stdout=subprocess.PIPE).communicate())
        project_timestamp.write("," + commit + "," + data[3:-16] + "\n")
    commits.close()

    return 

#Função para obter timestamp das maiores similaridades, gerando assim a evolução
def get_evolution_timestamp(token, greater_similarity_timestamp, evolution):
    commits = open("greater_similarity/" + token + "/" + token + "_greater_similarity.csv") 
    
    timestamp = []
    for commit in commits:
        commit = commit.split(',')[0]
        data = str(subprocess.Popen(["git", "-C", "github_repos/" + token + "/" + token, "show",  "-s", "--format=" + "%ci" , commit], stdout=subprocess.PIPE).communicate())
        timestamp.append(data[3:-16])
    commits.close()

    commits = open("greater_similarity/" + token + "/" + token + "_greater_similarity.csv")
    
    for line, time in zip(commits , timestamp):
        line = line.replace("\n","")
        if line == "commit,[similarity,combination]" or time == "":
            continue
        text = '{},{}'.format(line,time)
        greater_similarity_timestamp.write("," + text + "\n")
        text = '{},{}'.format(line.split(',')[1].replace("[","").replace("'",""),time) 
        evolution.write("," + text + "\n")
    
    commits.close()
    return

#Função para obter dados gerais somando todos os repositórios(Total de Issues, total de contribuidores, total de commits 
def get_general_insights(general_insights):
    data = open("repositories_insights/" + "repository_insights.csv")
    df = pd.read_csv(data, usecols=["total_commits","contributors_amount"])

    issues = open("repositories_insights/" + "issues_insights.csv")
    df_issues = pd.read_csv(issues, usecols=["number","state"])

    contributors = 0
    commits = 0
    for line in df.itertuples():
        if pd.notnull(line.contributors_amount):
            contributors += int(line.contributors_amount)
            commits += int(line.total_commits)
    
    open_issues = 0
    closed_issues = 0
    issues = 0
    for line in df_issues.itertuples():
        if pd.notnull(line.number):
            issues += 1
            if line.state == "open":
                open_issues += 1
            else:
                closed_issues += 1

    
    general_insights.write(str(commits) + "," + str(contributors) + ','
    + str(issues) + ',' + str(open_issues) + ',' + str(closed_issues))
    return
 
#########################Início#########################
print("Obtendo insghts dos projetos...")

#Criando arquivos de insights
contributors = open("repositories_insights/" + "contributors_insights.csv", "w")
contributors.write("token,commits_per_author,author\n")

insights = open("repositories_insights/" + "repository_insights.csv", "w")
insights.write("token,total_commits,contributors_amount\n")

issues_insights = open("repositories_insights/" + "issues_insights.csv", "w")
issues_insights.write("token,number,title,user_name,state,created_at,updated_at,closed_at\n")

project_timestamp = open("repositories_insights/" + "project_timestamp.csv", "w")
project_timestamp.write("token,commit,timestamp\n")

greater_similarity_timestamp = open("repositories_insights/" + "greater_similarity_timestamp.csv", "w")
greater_similarity_timestamp.write("token,commit,[similarity,combination],timestamp\n")

evolution = open("repositories_insights/" + "evolution_insights.csv", "w")
evolution.write("token,similarity,timestamp\n")

general_insights = open("repositories_insights/" + "general_insights.csv", "w")
general_insights.write("commits,contributors,issues_amount,open_issues,closed_issues\n")

for token, repo in zip(tokens, repos):
    # Criando diretórios
    path = "repositories_insights/"
    try:
        os.mkdir(path+token)
    except OSError:
        print ("Creation of the directory %s failed" % path)

    Obtendo colaboradores e número de commits de cada um
    get_contributors_insights(contributors, token) 
    contributors.write(token+', ,\n')

    #Obtendo número total de commits e total de colaboradoes
    contributors_amount = get_contributors_amount(repo)
    commits_amount = get_commits_insights(token)
    insights.write(','+str(commits_amount.replace('\n', ''))+','+str(contributors_amount)+'\n')
    insights.write(token+", ,\n")

    # Obtendo dados referentes a issues
    get_issues_insights(repo,issues_insights)
    issues_insights.write(token+", , , , , , ,  \n")

    # Obtendo Timestamp dos projetos
    get_timestamp(token,project_timestamp)
    project_timestamp.write(token+", ,\n")

    #obtendo timestamp de evolução dos projetos 
    get_evolution_timestamp(token,greater_similarity_timestamp, evolution)
    greater_similarity_timestamp.write(token+", , , \n")
    evolution.write(token+", ,  \n")
    
    print(token + " - Concluído!")

# Obtendo dados gerais sobre projetos
get_general_insights(general_insights)

contributors.close()
insights.close()
issues_insights.close()
project_timestamp.close()
greater_similarity_timestamp.close()
evolution.close()
general_insights.close()
