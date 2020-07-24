// This module contains the Solver class used for finding the optimal distribution of disciplines.
//
// Author: Ondrej Holub

import 'dart:math';
import 'package:disciplinovac/classes/discipline.dart';
import 'package:disciplinovac/classes/person.dart';
import 'package:disciplinovac/classes/solution.dart';

/// Class Solver responsible for all the calculations necessary for the search of optimal solutions.
class Solver{

  /// Optimal solutions found by the solver.
  static List<Solution> solutions;

  /// Solution nodes to be explored.
  static List<Solution> _solutionStack;

  /// Number of disciplines to be distributed.
  static int nrOfDisciplines;

  /// Minimal number of conflicts found by the solver.
  static int minConflicts;

  /// Starts the solving algorithm.
  static solve() {
    _init();
    Solution s;
    while( _solutionStack.isNotEmpty ){
      s = _solutionStack.removeLast();
      _branchAndBound(s);
    }
    _sortSolutions();
  }

  /// Initialize the solver to be ready for the next calculation.
  static void _init(){
    solutions = [];
    _solutionStack = [Solution()];  // Solution stack should contain a single, root (empty) solution.
    minConflicts = Person.people.length;  // Should be a number that at least the same as the number of conflicts in the worst case.
    nrOfDisciplines = Discipline.disciplines.length;
  }

  /// Perform branching and a combined version of bounding of the Branch and Bound algorithm.
  static void _branchAndBound(Solution parent){

    // Eager bounding, node is thrown away as it cannot lead to an optimal result.
    if(parent.conflicts() > Solver.minConflicts){
      return;
    }

    List<Solution> children = parent.branch();

    // Lazy bounding.
    if(children.isNotEmpty && children[0].isFinal()){
      // Bounding final nodes.
      for(Solution child in children){
        if(child.conflicts() < Solver.minConflicts){
          Solver.minConflicts = child.conflicts();
          Solver.solutions = [child];
        }
        else if(child.conflicts() == Solver.minConflicts){
          Solver.solutions.add(child);
          _filterSolutions();
        }
      }
    }else{
      // Bounding non-final nodes.
      for(Solution child in children){
        if(child.conflicts() <= Solver.minConflicts){
          Solver._solutionStack.add(child);
        }
      }
    }
  }

  /// Filter calculated solutions to prevent memory overflow.
  /// 
  /// Filtering occurs only on large samples of data (>25 disciplines) for which this application is not recommended to use.
  /// When application is use as intended, this method does not have any effect.
  static void _filterSolutions(){
    if(Solver.solutions[0].conflictingParticipants.length == 0){
      if(Solver.solutions.length > 400){
        // Found more than plenty of optimal solutions. Continuing could only lead to solutions with more evenly distributed participants.
        // Returning results of possibly non-optimally distributed participants.
        _solutionStack = [];
      }
    }else{
      if(Solver.solutions.length > 500){
        // Reducing the list of found solutions, some optimal solutions might be unreachable due to this step.
        List<Solution> tmp = [];
        Random rand = Random();
        for(int i=0; i<100; i++){
          int index = rand.nextInt(Solver.solutions.length-1);
          Solution s = Solver.solutions.removeAt(index); 
          tmp.add(s);
        }
        Solver.solutions = tmp;
      }
    }
  }

  /// Sorts solutions by dispersion of participants among rounds.
  static _sortSolutions(){
    Solution x = solutions.removeLast();  //to have something for comparison when inserting a solution into sorted list
    x.calculateDispersion();
    List<Solution> sorted = [x];

    for(Solution s in solutions){
      s.calculateDispersion();
      int i = sorted.indexWhere((sortedSolution) => (s.dispersion <= sortedSolution.dispersion));
      if(i == -1){
        sorted.add(s);
      }else{
        sorted.insert(i, s);
      }
    }
    solutions = sorted;
  }
}