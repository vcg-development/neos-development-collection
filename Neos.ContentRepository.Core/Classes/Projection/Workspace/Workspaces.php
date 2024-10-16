<?php

/*
 * This file is part of the Neos.ContentRepository package.
 *
 * (c) Contributors of the Neos Project - www.neos.io
 *
 * This package is Open Source Software. For the full copyright and license
 * information, please view the LICENSE file which was distributed with this
 * source code.
 */

declare(strict_types=1);

namespace Neos\ContentRepository\Core\Projection\Workspace;

use Neos\ContentRepository\Core\SharedModel\Workspace\WorkspaceName;

/**
 * An immutable, type-safe collection of Workspace objects
 *
 * @implements \IteratorAggregate<int,Workspace>
 *
 * @api
 */

final class Workspaces implements \IteratorAggregate, \Countable
{
    /**
     * @var array<string,Workspace>
     */
    private array $workspaces;

    /**
     * @param iterable<mixed,Workspace> $collection
     */
    private function __construct(iterable $collection)
    {
        $workspaces = [];
        foreach ($collection as $item) {
            if (!$item instanceof Workspace) {
                throw new \InvalidArgumentException(
                    'Workspaces can only consist of ' . Workspace::class . ' objects.',
                    1677833509
                );
            }
            $workspaces[$item->workspaceName->value] = $item;
        }

        $this->workspaces = $workspaces;
    }

    /**
     * @param array<mixed,Workspace> $workspaces
     */
    public static function fromArray(array $workspaces): self
    {
        return new self($workspaces);
    }

    public static function createEmpty(): self
    {
        return new self([]);
    }

    public function get(WorkspaceName $workspaceName): ?Workspace
    {
        return $this->workspaces[$workspaceName->value] ?? null;
    }

    /**
     * Get all base workspaces (if they are included in this result set).
     */
    public function getBaseWorkspaces(WorkspaceName $workspaceName): Workspaces
    {
        $baseWorkspaces = [];

        $workspace = $this->get($workspaceName);
        if (!$workspace) {
            return Workspaces::createEmpty();
        }
        $baseWorkspaceName = $workspace->baseWorkspaceName;
        while ($baseWorkspaceName != null) {
            $baseWorkspace = $this->get($baseWorkspaceName);
            if ($baseWorkspace) {
                $baseWorkspaces[] = $baseWorkspace;
                $baseWorkspaceName = $baseWorkspace->baseWorkspaceName;
            } else {
                $baseWorkspaceName = null;
            }
        }
        return Workspaces::fromArray($baseWorkspaces);
    }

    /**
     * Get all dependent workspaces (if they are included in this result set).
     */
    public function getDependantWorkspaces(WorkspaceName $workspaceName): Workspaces
    {
        return $this->filter(
            static fn (Workspace $potentiallyDependentWorkspace) => $potentiallyDependentWorkspace->baseWorkspaceName?->equals($workspaceName) ?? false
        );
    }

    /**
     * @return \Traversable<int,Workspace>
     */
    public function getIterator(): \Traversable
    {
        yield from array_values($this->workspaces);
    }

    /**
     * @param \Closure(Workspace): bool $callback
     */
    public function filter(\Closure $callback): self
    {
        return new self(array_filter($this->workspaces, $callback));
    }

    /**
     * @param \Closure(Workspace): bool $callback
     */
    public function find(\Closure $callback): ?Workspace
    {
        foreach ($this->workspaces as $workspace) {
            if ($callback($workspace)) {
                return $workspace;
            }
        }
        return null;
    }

    /**
     * @template T
     * @param \Closure(Workspace): T $callback
     * @return list<T>
     */
    public function map(\Closure $callback): array
    {
        return array_map($callback, array_values($this->workspaces));
    }

    public function count(): int
    {
        return count($this->workspaces);
    }

    public function isEmpty(): bool
    {
        return $this->workspaces === [];
    }
}
