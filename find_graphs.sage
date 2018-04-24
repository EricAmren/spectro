#load("spectro.sage")
#sys.setrecursionlimit(20000)
ds=[3,3,2,2]
ds=[3,3,2,2,1,1]
ds=[5,4,2,2,2,1]
ds=[4,4,3,3,2,1,1]
ds=[6,4,4,3,3,1,1]

class Node:
    def __init__(self, degreeSequence):
        self.degreeSequence = degreeSequence
        self.freeBonds = getMaxFreeBonds(self.degreeSequence)

    def __str__(self):
        return str(self.degreeSequence)

    def getNumberOfFreeBonds(self):
        seq = self.degreeSequence
        if len(seq) == 1:
            self.freeBonds = seq[0]
        else:
            seq.append(1)
            while sum( i > 0 for i in seq ) > 1:
                for degree in seq:
                    if degree == 0:
                        seq.pop(degree)
                maxId = seq.index(max(seq)) # Index of max degree
                minId = seq.index(min(seq)) # Index of min degree
                seq[maxId] -= 1
                seq[minId] -= 1
            #at least 2 vertex with degree > 0

            self.freeBonds = sum( j for j in seq )

class Vertex:
    def __init__(self, index, degree):
        self.index = index
        self.degree = degree

def getMaxFreeBonds(degreeSequence):
    freeBonds = 0
    if degreeSequence == None :
        return freeBonds
    for degree in degreeSequence:
        freeBonds += int(degree)
    freeBonds -= 2 * (len(degreeSequence) - 1)
    return freeBonds

def buildParentNode(nodeList):
    """
    Build parent node by merging
    """
    degreeSequence = []
    freeBonds = 0
    numberOfChildren = 0
    sum = 0
    for node in nodeList:
        degreeSequence.extend(node.degreeSequence)
        degreeSequence.sort(reverse=True)
        numberOfChildren += 1
        sum += node.freeBonds

    node = Node(degreeSequence)
    node.freeBonds = sum - 2 * (numberOfChildren - 1)
    return node



def verif(ds):
    sol_all=[]
    for i in range(500):
        G=graphs.DegreeSequenceConfigurationModel(ds)
        if is_unique_and_connected(G, sol_all):
            if not G.has_loops():
                sol_all.append(G)
    return sol_all

def switch(G, v0, v1, v2, v3):
    """
    Switches 2 edges and returns a new graph.
    v0v2 and v1v3 must be edges.
    """
    new_G = copy(G)
    new_G.add_edge(v0,v1)
    new_G.add_edge(v2,v3)
    new_G.delete_edge(v0,v2)
    new_G.delete_edge(v1,v3)
    return new_G

def graph2hash(graph):
    hash = graph.canonical_label().sparse6_string()
    return hash

def hash2graph(hash):
    graph = Graph(hash, loops=False, multiedges=True, data_structure="sparse")
    return graph

def has_isomorph(new_graph, graphs_list):
    """
    Checks whether a graph is isomorphic with any graph of a list.
    Returns a boolean.
    """
    if not graphs_list: #If list is empty, no need to check
        return False
    for graph in graphs_list:
        if new_graph == graph:  # True if an isomorph has been found
            return True
    return False

def find_neutral_graph(ds):
    ### TODO : verify that a graph can be obtained
    G = Graph(len(ds), loops=False, multiedges=True)
    if len(ds) == 0:
        return G
    vertices_list = []
    for i in range(len(ds)):
        vertices_list.append(Vertex(i, ds[i]))
    vertices_list.sort(key=operator.attrgetter('degree'), reverse=True)
    while any(v.degree for v in vertices_list) != 0:
        #Sorting vertices by degree
        max_vertex = vertices_list[0]
        if max_vertex == 0:
            raise ValueError("Max degree is zero.")
        for i in range(0, min(len(ds), max_vertex.degree + 1) - 1):
        # distributing degrees of max vertex
            next_vertex = vertices_list[i+1]
            if next_vertex.degree == 0:
                continue
            else:
                max_vertex.degree -=1
                next_vertex.degree -=1
                G.add_edge(max_vertex.index, next_vertex.index)
        vertices_list.sort(key=operator.attrgetter('degree'), reverse=True)
    return G


def find_all_graphs(ds):
    """
    Given a degree sequence, builds a multigraph and returns all connected
    non-isomorphic multigraphs found by switching pairs of edges.
    """
    #G=graphs.DegreeSequence(ds)
    #G.allow_multiple_edges(True)
    G = find_neutral_graph(ds)
    results=set()
    if G.has_loops():
        raise ValueError("Loops aren't allowed") #TODO
    stack=[G]
    # if not G.is_connected():
    #    raise ValueError("first graph isn't connected") #TODO
    if G.is_connected():
        results.add(graph2hash(G))
    results = rec(stack, results)
    results_graphs =[]
    for hash in results:
        results_graphs.append(hash2graph(hash))
    return results_graphs


def rec(stack, results):
    while stack != []:
        G = stack.pop()
        edges = G.edges()
        for i in range(len(edges)-1):
            e1 = edges[i]
            for j in range(i+1, len(edges)):
                e2 = edges[j]
                if e1[0] not in e2 and e1[1] not in e2: # No edges sharing vertex
                    G1 = switch(G, e1[0], e2[0], e1[1], e2[1])
                    G2 = switch(G, e1[1], e2[0], e1[0], e2[1])
                    for g in [G1, G2]:
                        h = graph2hash(g)
                        if g.is_connected() and not h in results :
                            results.add(h)
                            stack.append(g)
                            rec(stack, results)
    return results

def label2seq(label):
    degreeSequence = []
    for degree in str(label):
        degreeSequence.append(int(degree))
    return degreeSequence



################################################################################

LRT = LabelledRootedTree

node011 = Node([4,1])
node012 = Node([3,2])
node021 = Node([4,2])
node022 = Node([4,3,1])
node01 = buildParentNode([node011, node012])
node02 = buildParentNode([node021, node022])
node0 = buildParentNode([node01, node02])

lrt011 = LRT([], node011)
lrt012 = LRT([], node012)
lrt021 = LRT([], node021)
lrt022 = LRT([], node022)
lrt01 = LRT((lrt011, lrt012), node01)
lrt02 = LRT((lrt021, lrt022), node02)
root = LRT((lrt01, lrt02), node0)


################################################################################

def has_isomorph_old(new_graph, graphs_list):
    """
    Checks whether a graph is isomorphic with any graph of a list.
    Returns a boolean.
    """
    if not graphs_list: #If list is empty, no need to check
        return False
    for graph in graphs_list:
        if new_graph.is_isomorphic(graph):  # True if an isomorph has been found
            return True
    return False

def is_unique_and_connected_old(new_graph, graphs_list):
    """
    Returns True if a graph is connected and if it isn't isomorphic to any graph
    of a list.
    """
    if new_graph.is_connected():
        if not graphs_list: # If list is empty
            return true
        else:
            if has_isomorph(new_graph, graphs_list):
                return False
            else:
                return True
    else:
        return False

def find_all_graphs_old(ds):
    """
    Given a degree sequence, builds a multigraph and returns all connected
    non-isomorphic multigraphs found by switching pairs of edges.
    """
    G=graphs.DegreeSequence(ds)
    G.allow_multiple_edges(True)
    results=[]
    if G.has_loops():
        raise ValueError("Loops aren't allowed") #TODO
    stack=[G]
    if not G.is_connected():
        raise ValueError("first graph isn't connected") #TODO
    if G.is_connected():
        results=[G]
    return rec(stack, results)

def rec_old(stack, results):
    while stack != []:
        G = stack.pop()
        edges = G.edges()
        for i in range(len(edges)-1):
            e1 = edges[i]
            for j in range(i+1, len(edges)):
                e2 = edges[j]
                if e1[0] not in e2 and e1[1] not in e2: # No edges sharing vertex
                    G1 = switch(G, e1[0], e2[0], e1[1], e2[1])
                    G2 = switch(G, e1[1], e2[0], e1[0], e2[1])
                    for g in [G1, G2]:
                        if is_unique_and_connected(g, results):
                            stack.append(g)
                            results.append(g)
                            rec(stack, results)
                else:
                    continue
    return results
