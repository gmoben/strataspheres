#!/usr/bin/env python
import random
from collections import Counter


BLACK = 'b'
WHITE = 'w'


class Bag:

    """ A bag of black and white balls """

    def __init__(self, nBlack, nWhite):
        self.contents = [BLACK] * nBlack + [WHITE] * nWhite

    def draw(self):
        """ Remove and return at least 2 balls """
        k = 2 if len(self.contents) >= 2 else 1  # for simplicity
        sample = random.sample(self.contents, k)
        [self.contents.remove(ball) for ball in sample]
        return sample

    def returnBall(self, ball):
        """ Return a ball to the bag """
        self.contents.append(ball)

    def returnBalls(self, balls):
        """ Return multiple balls to the bag """
        [self.returnBall(ball) for ball in balls]


class Simulation:

    """ A simulation for sequentially removing/replacing balls from a bag """

    def __init__(self, iterations, nBlack=25, nWhite=25):
        self.iterations = iterations
        self.nBlack = nBlack
        self.nWhite = nWhite

    def run(self):
        """
        Run the simulation for the given number of iterations
        """
        self.results = []
        for x in xrange(self.iterations):
            bag = Bag(self.nBlack, self.nWhite)
            balls = bag.draw()
            while len(balls) == 2:
                if balls == [BLACK] * 2:
                    bag.returnBalls(balls)
                # elif balls == [WHITE] * 2:
                    # Do nothing!
                elif all(x in balls for x in [BLACK, WHITE]):
                    bag.returnBall(WHITE)
                balls = bag.draw()
            self.results.append(balls[0])
        self.printResults()

    def printResults(self):
        """
        Print the percent likelihood of each ball type being the remaining ball
        """
        c = Counter(self.results)

        def result(name, count):
            return name + ': ' + \
                "{:.2f}".format((count / self.iterations) * 100) + '%' + \
                ' [' + str(count) + '/' + str(self.iterations) + ']'

        print(result('BLACK', c[BLACK]))
        print(result('WHITE', c[WHITE]))


if __name__ == "__main__":
    simulation = Simulation(1000)
    simulation.run()
