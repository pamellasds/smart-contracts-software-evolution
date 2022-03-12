import subprocess
import glob
import os
from fuzzywuzzy import fuzz
import re
import pandas as pd
import csv
import codecs

#Função para recuperar lista de commits
def get_commits(token):
    commits_file = open("github_commits/" + token + "_commits.txt")
    commits = []

    for line in commits_file:
        line = line.replace("\n","")

        commits.append(line)

    commits_file.close()

    commits.reverse()
    return commits

#Função para encontrar arquivo com maior similaridade
def get_greater_similarity(token, commits):
    # Criando repositórios
    path = "greater_similarity/"
    try:
        os.mkdir(path+token)
    except OSError:
        print ("Creation of the directory %s failed" % path)
    
    greater_similarity_file = open("greater_similarity/" + token + "/" +  token + "_greater_similarity.csv", "w")
    greater_similarity_file.write("commit,[similarity,combination]\n")
    
    greater_similarity = 0
    tup = ""
    
    # Para cada commit obtem-se o arquivo csv contendo as maiores similaridades das combinações
    for commit in commits:
        
        csv_files_in_folder = []
        for csv_file in glob.glob("results_combinations/" + token + "/" +  commit + "**/*.csv"):
            csv_files_in_folder.append(csv_file)
        

        for line in csv_files_in_folder:
            with open(line, 'r') as csv_file:
                csv_reader = csv.reader(csv_file, delimiter=',')
                
                try:
                    for column in csv_reader:
                        if column[0] == 'similarity':
                            continue
                        elif int(column[0]) > greater_similarity:
                            greater_similarity =  int(column[0])
                            tup = column
                except csv.Error:
                    print("Erro ao ler csv")

        # print(tup)
        greater_similarity_file.write(commit + "," + str(tup) + "\n")
    
    greater_similarity_file.close()
    return
    
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


for token in tokens:
    
    print(token + ' maiores similaridades')
    commits = get_commits(token)
    get_greater_similarity(token, commits)
    print("--------------------------------")
