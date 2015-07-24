#!/usr/bin/env escript

%% Main program
main(_) ->
  Iterations = 1000,
  Results = run(Iterations),
  printResults(Results, Iterations).

%%%%%%%%%%%
%%% Bag %%%
%%%%%%%%%%%

%% Create a representation for a bag of black and white balls.
createBag(NBlack, NWhite) ->
  Bag = lists:flatmap(fun({X, N}) -> lists:duplicate(N, X) end, [{b, NBlack}, {w, NWhite}]),
  shuffle(Bag).

%% Draw 2 elements recursively from a bag and return the last remaining element.
recursiveDraw(Bag) ->
  Len = length(Bag),
  if Len > 1 ->

    {Selection, Remaining} = drawTwo(Bag),
    NewBag = if Selection == [b, b] -> Bag;
                Selection == [w, w] -> Remaining;
                Selection == [b, w] -> lists:merge([w], Remaining);
                Selection == [w, b] -> lists:merge([w], Remaining);
                true -> printError('Unknown selection', Selection)
             end,
    recursiveDraw(NewBag);

    Len =:= 1 -> Bag;

    true -> printError('Recursive Draw Error')
  end.

%% Retrieve a single element from a bag and return the element and remainder.
drawOne(Bag) ->
  Len = length(Bag),
  I = random:uniform(Len),
  Elem = lists:nth(I, Bag),
  {Elem, lists:delete(Elem, Bag)}.

%% Retrieve two elements from a bag.
drawTwo(Bag) ->
  {Elem1, Draw1} = drawOne(Bag),
  {Elem2, Remaining} = drawOne(Draw1),
  {[Elem1, Elem2], Remaining}.

%%%%%%%%%%%%%%%%%%
%%% Simulation %%%
%%%%%%%%%%%%%%%%%%

%% Run the simulation the given number of times and return all the final elements.
run(Iterations) ->
  run([], Iterations).
run(PreviousResults, RemainingIterations) ->
  NBlack = 25,
  NWhite = 25,
  Bag = createBag(NBlack, NWhite),
  if RemainingIterations > 0 ->
    NewResult = recursiveDraw(Bag),
    NewResults = lists:merge(NewResult, PreviousResults),
    run(NewResults, RemainingIterations - 1);

    RemainingIterations =:= 0 -> PreviousResults;
    true -> printError('Invalid iteration count', RemainingIterations)
  end.

%% Print the percent likelihood of each ball type being the remaining ball.
printResults(Results, Iterations) ->
  BCount = count(b, Results),
  WCount = count(w, Results),
  BResult = resultString('BLACK', BCount, Iterations),
  WResult = resultString('WHITE', WCount, Iterations),
  io:format(BResult),
  io:format(WResult).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Convenience Functions %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Print an error with an optional extra argument.
printError(Name, X) ->
  io:format("Error: ~s ~p\n", [Name, X]).
printError(Name) ->
  io:format("Error: ~p\n", [Name]).

%% Randomly shuffle a list
shuffle(L) ->
  random:seed(now()),
  [X||{_,X} <- lists:sort([ {random:uniform(), N} || N <- L])].

%% Return the number of occurrences in a list.
count(Item, L) ->
  C = lists:filter(fun(X) -> X == Item end, L),
  length(C).

%% Build a formatted result string.
resultString(Name, Count, Iterations) ->
  Percentage = (Count / Iterations) * 100,
  io_lib:format("~s: ~.2.0f% [~w / ~w]~n", [Name, Percentage, Count, Iterations]).
