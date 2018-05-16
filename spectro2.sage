from operator import attrgetter
from itertools import combinations

def TODO():
    raise NotImplementedError("To be implemented")



class Node:
    def __init__(self, atoms = []):
        self.parent = None
        self.children = []
        self.atoms = atoms

    def add_children(self, children):
        for child in children:
            if child not in self.children:
                self.children.append(child)
                child.parent = self
    def is_root(self):
        return self.parent == None

    def is_connected(self, G):
        vertices = [atom.vertex for atom in self.atoms]
        subgraph = G.subgraph(vertices)
        return subgraph.is_connected()

class Atom:
    def __init__(self):
        self.vertex = None  # Index of this atom in general graph
        self.valence = None
        self.freeBonds = 0

def build_atom(valence):
    atom = Atom()
    atom.valence = valence
    atom.freeBonds = valence
    return atom

def connect_2_atoms(G, atom1, atom2):
    G.add_edge(atom1.vertex, atom2.vertex)
    atom1.freeBonds -= 1
    atom2.freeBonds -= 1

def connect_leaves(list_of_leaves, G):
    for leaf in list_of_leaves:
        connected_atoms = set()
        while not leaf.is_connected(G):
            sorted_atoms = sorted(leaf.atoms, key=attrgetter('freeBonds'), reverse=True)
            all_pairs = combinations(sorted_atoms, 2)
            for pair in all_pairs:
                atom1 = pair[0]
                atom2 = pair[1]
                if atom1 in connected_atoms and atom2 in connected_atoms:
                    pass
                else:
                    connect_2_atoms(G, atom1, atom2)
                    connected_atoms.update(pair)
                    break

def connect_node(node, G):
    connected_children = set()
    while not node.is_connected(G):
        max_atoms_of_children = []
        for child in node.children:
            max_atom = max(child.atoms, key=attrgetter('freeBonds'))
            max_atoms_of_children.append((max_atom, child))
        max_atoms_of_children.sort(reverse=True)
        all_pairs = combinations(max_atoms_of_children, 2)
        for pair in all_pairs:
            atom1 = pair[0][0]
            atom2 = pair[1][0]
            child1 = pair[0][1]
            child2 = pair[1][1]
            if child1 in connected_children and child2 in connected_children:
                pass
            else:
                connect_2_atoms(G, atom1, atom2)
                connected_children.add(child1)
                connected_children.add(child2)
                break

def fill_remaining_bonds(root,G):
    unfilled_atoms = []
    for atom in root.atoms:
        if atom.freeBonds != 0:
            unfilled_atoms.append(atom)
    while unfilled_atoms != []:
        sorted_atoms = sorted(unfilled_atoms, key=attrgetter('freeBonds'), reverse=True)
        atom1 = sorted_atoms[0]
        atom2 = sorted_atoms[1]
        connect_2_atoms(G, atom1, atom2)
        unfilled_atoms = []
        for atom in root.atoms:
            if atom.freeBonds != 0:
                unfilled_atoms.append(atom)

################################ TESTING SETS ###################################
## Set1
C1 = build_atom(4)
C2 = build_atom(4)
C3 = build_atom(4)
N1 = build_atom(3)
N2 = build_atom(3)
O1 = build_atom(2)
O2 = build_atom(2)
H1 = build_atom(1)
H2 = build_atom(1)

n1 = Node([C1,H1])
n2 = Node([N1,O1])
n3 = Node([C2,O2])
n4 = Node([C3,N2,H2])
# n4 = Node([N2,H2,C3])
n5 = Node(n1.atoms + n2.atoms)
n5.add_children([n1,n2])
n6 = Node(n3.atoms + n4.atoms)
n6.add_children([n3,n4])
root = Node(n5.atoms + n6.atoms)
root.add_children([n5,n6])
leaves = [n1,n2,n3,n4]

## Set2
C1 = build_atom(4)
C2 = build_atom(4)
N1 = build_atom(3)
N2 = build_atom(3)
N3 = build_atom(3)
O1 = build_atom(2)
O2 = build_atom(2)
H1 = build_atom(1)
H2 = build_atom(1)
H3 = build_atom(1)

n1 = Node([C1])
n2 = Node([N1])
n3 = Node([O1,H1])
n4 = Node([N2,O2])
n5 = Node([N3,H2])
n6 = Node([C2,H3])

N1 = Node(n1.atoms + n2.atoms + n3.atoms)
N1.add_children([n1,n2,n3])
N2 = Node(n4.atoms + n5.atoms)
N2.add_children([n4,n5])
N3 = Node(n6.atoms)
N3.add_children([n6])
root = Node(N1.atoms + N2.atoms + N3.atoms)
root.add_children([N1,N2,N3])
leaves = [n1,n2,n3,n4,n5,n6]

G = Graph(0, loops=False, multiedges=True)
index = 0
for leaf in leaves:
    for atom in leaf.atoms:
        G.add_vertex()
        atom.vertex = index
        index += 1

connect_leaves(leaves, G)
connect_node(N1, G)
connect_node(N2, G)
connect_node(N3, G)
connect_node(root, G)
fill_remaining_bonds(root, G)
print(G.edges())




